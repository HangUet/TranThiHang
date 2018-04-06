class Api::V1::Vouchers::ReceivedEndDayController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def index
    typees = Voucher.typees[:import_end_day]
    @vouchers = Voucher.order(created_at: :desc)
                       .where(issuing_agency_id: @current_user.issuing_agency_id, typee: typees)
                       .ransack(code_or_sender_or_receiver_cont: params[:keyword]).result
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

    # check loi thuoc. toi uu sau

    medicines.each do |medicinex|
      if medicinex[:medicine_id] == nil

        medicine = Medicine.allocation.find_by id: medicinex[:id]
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
        medicine = Medicine.allocation.find_by id: medicinex[:medicine_id]
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

    # ---------------

    if @voucher.present?

      @voucher.update_attributes sender: voucher_params[:sender],
                                 receiver: voucher_params[:receiver]

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

  private

  def add_new_medicines_to_voucher medicinex
    medicine = Medicine.allocation.where(id: medicinex["id"]).first

    if medicine.present?
      if medicine.remaining_number >= medicine.booking + number_order
        VoucherMedicine.create medicine_id: medicinex["id"], voucher_id: @voucher.id, number: medicinex[:number_order]
        medicine.update_attributes(booking: (medicine.booking + number_order))
      else
        render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
        return
      end
    else
      render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại"}
      return
    end
  end

  def update_current_medicines medicinex
    medicine = Medicine.allocation.find_by id: medicinex[:medicine_id]
    if medicine
      number_order = medicinex[:number_order].to_i

      voucher_medicine = VoucherMedicine.where(medicine_id: medicine.id, voucher_id: @voucher.id).first

      if medicine.present?
        if medicine.remaining_number + voucher_medicine.number >= medicine.booking + number_order
          medicine.update_attributes booking: (medicine.booking + number_order - voucher_medicine.number)
          voucher_medicine.update_attributes number: number_order
        else
          render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
          return
        end
      else
        render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại"}
        return
      end
    end
  end
end
