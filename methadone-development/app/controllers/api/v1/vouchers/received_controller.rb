class Api::V1::Vouchers::ReceivedController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def index
    typees = [2, 3, 4]
    @vouchers = Voucher.order(created_at: :desc)
                       .where(issuing_agency_id: @current_user.issuing_agency_id, typee: typees)
                       .ransack(code_or_sender_or_receiver_cont: params[:keyword]).result
  end

  def search_voucher
    type = params[:voucher][:type].present? ? [Voucher.typees[params[:voucher][:type].to_sym]] : [2, 3, 4]
    status = params[:voucher][:status].present? ? params[:voucher][:status].to_sym : nil
    date_start = params[:voucher][:date_end].to_date rescue nil
    date_end = params[:voucher][:date_start].to_date rescue nil
    provider_id = params[:voucher][:provider] rescue nil
    code = params[:voucher][:code].present? ? params[:voucher][:code].gsub(" ", "") : nil
    @vouchers = Voucher.distinct(:id)
                        .order(created_at: :desc)
                        .where(issuing_agency_id: @current_user.issuing_agency_id)
                        .ransack(code_cont: code,
                          typee_in: type,
                          datee_lteq: date_start,
                          datee_gteq: date_end,
                          status_eq: Voucher.statuses[status],
                          medicines_provider_id_eq: provider_id).result
  end

  def update

    medicines = params[:voucher][:medicines]

    if medicines == nil
      render json: {code: 2, message: "Không có thuốc trong phiếu."}
      return
    end

    voucher_params = params[:voucher]

    unless voucher_params[:total_money] < 20000000000
      render json: {code: 2, message: "Tổng tiền quá lớn."}
      return
    end

    voucher = Voucher.where(id: voucher_params[:id],
                            issuing_agency_id: @current_user.issuing_agency_id).first

    if voucher.user_id != current_user.id
      render json: {code: 2, message: "Không thể sửa phiếu này."}
      return
    end

    if voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã xác nhận không thể sửa."}
      return
    end

    medicine_production_batchs = medicines.map{|m| [m[:name], m[:composition], m[:concentration],
      m[:packing], m[:provider], m[:production_batch], m[:expiration_date], m[:price]]}
    if medicine_production_batchs.uniq.length != medicine_production_batchs.length
      render json: {code: 2, message: "Trong phiếu chứa thuốc trùng lô."}
      return
    end

    # check thuoc loi. toi uu sau

    medicines.each do |medicinex|
      if medicinex[:medicine_id] == nil

        medicine_list = MedicineList.where(id: medicinex[:id]).first
        unless medicine_list.present?
          render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
          return
        end
      else
        medicine = Medicine.pending.find_by id: medicinex[:medicine_id]
        if medicine

          voucher_medicine = VoucherMedicine.where(medicine_id: medicine.id, voucher_id: voucher.id).first

          if voucher_medicine == nil
            render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
          end
          unless medicinex[:number_order] > 0
            render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
            return
          end
        else
          render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
          return
        end
      end
    end

    # --------------

    provider = Provider.where(id: voucher_params[:provider_id]).first

    unless provider.present?
      render json: {code: 2, message: "Nhà sản xuất không đúng."}
      return
    end

    if voucher.present?

      voucher.update_attributes sender: voucher_params[:sender],
                                receiver: voucher_params[:receiver],
                                datee: voucher_params[:datee],
                                total_money: voucher_params[:total_money],
                                invoice_number: voucher_params[:invoice_number]

      medicine_id_from_client = medicines.map{|m| m["medicine_id"]}
      medicine_ids = voucher.medicines.pluck(:id)

      deleted_medicine_ids = medicine_ids - medicine_id_from_client

      deleted_voucher_medicines = VoucherMedicine.where(voucher_id: voucher.id,
                                                        medicine_id: deleted_medicine_ids)

      if deleted_voucher_medicines.length > 0
        deleted_voucher_medicines.each do |voucher_medicine|
          temp_medicine = voucher_medicine.medicine
          temp_medicine.destroy
          voucher_medicine.destroy
        end
      end

      medicines.each do |medicinex|
        if medicinex[:medicine_id] == nil

          medicine_list = MedicineList.where(id: medicinex[:id]).first
          if medicine_list.present?

            medicine = Medicine.new issuing_agency_id: @current_user.issuing_agency_id,
                                       expiration_date: medicinex[:expiration_date],
                                       production_batch: medicinex[:production_batch],
                                       remaining_number: medicinex[:number_order],
                                       medicine_list_id: medicine_list.id,
                                       provider_id: provider.id,
                                       source: voucher_params[:source],
                                       price: medicinex[:price],
                                       division: :main,
                                       status: :pending

            if medicine.save

              voucher_medicine = VoucherMedicine.create number: medicinex[:number_order],
                                                        medicine_id: medicine.id, voucher_id: voucher.id
            else
              render json: {code: 2, message: "Cập nhật thất bại"}
              return
            end

          else
            render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
            return
          end
        else
          medicine = Medicine.pending.find_by id: medicinex[:medicine_id]
          if medicine

            voucher_medicine = VoucherMedicine.where(medicine_id: medicine.id, voucher_id: voucher.id).first

            if voucher_medicine == nil
              render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
            end
            if medicinex[:number_order] > 0
              medicine.update_attributes expiration_date: medicinex[:expiration_date],
                                         production_batch: medicinex[:production_batch],
                                         provider_id: provider.id,
                                         source: voucher_params[:source],
                                         price: medicinex[:price],
                                         remaining_number: medicinex[:number_order]

              voucher_medicine.update_attributes number: medicinex[:number_order]
            else
              render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
              return
            end
          else
            render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
            return
          end
        end
      end
      render json: {code: 1, message: "Cập nhật thành công."}
    else
      render json: {code: 2, message: "Cập nhật thất bại."}
    end
  end

  def destroy

    @voucher = Voucher.find_by(id: params[:id])

    if @voucher.user_id != current_user.id
      render json: {code: 2, message: "Không thể xóa phiếu này."}
      return
    end

    if @voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã xác nhận không thể xóa."}
      return
    end

    medicines = JSON.parse(@voucher.medicines.to_json)
    # Phai dua ra bien rieng.
    # Khi xoa voucher da xoa luon voucher_medicine
    # Khong con voucher_medicine

    voucher_typee = @voucher.typee
    if @voucher.destroy
      if voucher_typee == "import_from_allocation_agency"
        # Khong can lam gi ca. Chi can xoa voucher, voucher_medicine di la xong

        # medicines.each do |medicine|
        # med = Medicine.find_by id: medicine["id"]
        # if med
        #   med.update_attributes booking: (med.booking - medicine["number"].to_f)
        # end
      # end
      elsif voucher_typee == "import_from_distributor"
        # Xoa thuoc di la xong
        medicines.each do |medicine|
          med = Medicine.find_by id: medicine["id"]
          if med
            med.destroy
          end
        end
      end
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end
end
