class Api::V1::Vouchers::DeliveryController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def index
    typees = [0, 1, 5, 8]
    @vouchers = Voucher.order(created_at: :desc)
                       .where(issuing_agency_id: @current_user.issuing_agency_id, typee: typees)
                       .ransack(code_or_sender_or_receiver_cont: params[:keyword]).result
  end

  def search_voucher
    type = params[:voucher][:typee].present? ? [Voucher.typees[params[:voucher][:typee].to_sym]] : [0, 1, 5, 8]
    status = params[:voucher][:status].present? ? params[:voucher][:status].to_sym : nil
    date_start = params[:voucher][:date_end].to_date rescue nil
    date_end = params[:voucher][:date_start].to_date rescue nil
    sender = params[:voucher][:sender].present? ? params[:voucher][:sender].to_sym : nil
    receiver = params[:voucher][:receiver].present? ? params[:voucher][:receiver].to_sym : nil
    provider_id = params[:voucher][:provider] rescue nil
    code = params[:voucher][:code].present? ? params[:voucher][:code].gsub(" ", "") : nil
    @vouchers = Voucher.distinct(:id)
                       .order(created_at: :desc)
                       .where(issuing_agency_id: @current_user.issuing_agency_id)
                       .ransack(code_cont: code,
                         sender_cont: sender,
                         receiver_cont: receiver,
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

    @voucher = Voucher.where(id: voucher_params[:id],
                            issuing_agency_id: @current_user.issuing_agency_id).first

    if @voucher.user_id != current_user.id
      render json: {code: 2, message: "Không thể sửa phiếu này."}
      return
    end

    # check loi thuoc. toi uu sau

    medicines.each do |medicinex|
      if medicinex[:medicine_id] == nil

        medicine = Medicine.main.accepted.find_by id: medicinex[:id]
        if medicine
          number_order = medicinex[:number_order].to_i

          number = medicine.remaining_number - medicine.booking - number_order

          if number >= 0
          else
            render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
            return
          end
        else
          render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
          return
        end

      else
        medicine = Medicine.main.accepted.find_by id: medicinex[:medicine_id]
        if medicine
          number_order = medicinex[:number_order].to_i

          voucher_medicine = VoucherMedicine.where(medicine_id: medicine.id, voucher_id: @voucher.id).first

          if voucher_medicine == nil
            render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
            return
          end

          number = medicine.remaining_number + voucher_medicine.number - medicine.booking - number_order


          if number >= 0
          else
            render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
            return
          end
        end
      end
    end

    medicines.each do |medicinex|
      next if Date.parse(change_date_format(medicinex[:init_date])) <= Date.parse(change_date_format(params[:voucher][:datee]))
      render json: {code: 2, message: "Có thuốc mà ngày tạo lớn hơn ngày xuất phiếu"}
      return
    end

    # ---------------

    if @voucher.present?

      @voucher.update_attributes sender: voucher_params[:sender],
                                receiver: voucher_params[:receiver],
                                datee: voucher_params[:datee]

      medicine_id_from_client = medicines.map{|m| m["medicine_id"]}
      medicine_ids = @voucher.medicines.pluck(:id)

      deleted_medicine_ids = medicine_ids - medicine_id_from_client

      deleted_voucher_medicines = VoucherMedicine.where(voucher_id: @voucher.id, medicine_id: deleted_medicine_ids)

      if deleted_voucher_medicines.length > 0
        deleted_voucher_medicines.each do |voucher_medicine|
          temp_medicine = voucher_medicine.medicine
          temp_medicine.update_attributes booking: (temp_medicine.booking - voucher_medicine.number)
          voucher_medicine.destroy
        end
      end

      medicines.each do |medicinex|
        if medicinex[:medicine_id] == nil
          add_new_medicines_to_voucher medicinex
        else
          update_current_medicines medicinex
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

    unless @voucher.present?
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end

    if @voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã xác nhận không thể xóa."}
      return
    end

    # medicines = Medicine.select([Medicine.arel_table[Arel.star], VoucherMedicine.arel_table[:number]])
    #                     .where(VoucherMedicine.arel_table[:voucher_id].eq(@voucher.id))
    #                     .joins( Medicine.arel_table.join(VoucherMedicine.arel_table)
    #                     .on( Medicine.arel_table[:id].eq(VoucherMedicine.arel_table[:medicine_id])).join_sources)

    medicines = []

    @voucher.voucher_medicines.each do |voucher_medicine|
      temp_medicine = {id: voucher_medicine.medicine.id,
                  number: voucher_medicine.number}
      medicines.push temp_medicine
    end

    puts medicines[0]
    # Phai dua ra bien rieng.
    # Khi xoa voucher da xoa luon voucher_medicine
    # Khong con voucher_medicine
    if @voucher.destroy
      medicines.each do |medicine|
        med = Medicine.find_by id: medicine[:id]
        if med.present?
          temp_booking = med.booking - medicine[:number]
          med.update_attributes booking: temp_booking
        end
      end
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def add_new_medicines_to_voucher medicinex
    medicine = Medicine.main.accepted.find_by id: medicinex[:id]
    if medicine
      number_order = medicinex[:number_order].to_i

      if medicine.remaining_number >= medicine.booking + number_order
        voucher_medicine = VoucherMedicine.create number: number_order,
                                                  medicine_id: medicine.id, voucher_id: @voucher.id
        medicine.update_attributes(booking: (medicine.booking + number_order))
      else
        render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
        return
      end
    else
      render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
      return
    end
  end

  def update_current_medicines medicinex
    medicine = Medicine.main.accepted.find_by id: medicinex[:medicine_id]
    if medicine
      number_order = medicinex[:number_order].to_i

      voucher_medicine = VoucherMedicine.where(medicine_id: medicine.id, voucher_id: @voucher.id).first

      if voucher_medicine == nil
        render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
      end

      if medicine.remaining_number + voucher_medicine.number >= medicine.booking + number_order
        medicine.update_attributes(booking: (medicine.booking + number_order - voucher_medicine.number))
        voucher_medicine.update_attributes number: number_order
      else
        render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
        return
      end
    end
  end

  def change_date_format date_d_m_y
    date_d_m_y.split("/").reverse.join("/")
  end
end
