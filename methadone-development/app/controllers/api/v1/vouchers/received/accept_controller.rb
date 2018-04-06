class Api::V1::Vouchers::Received::AcceptController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def update
    @voucher = Voucher.find_by(id: params[:id])

    if @voucher.user_id != current_user.id
      render json: {code: 2, message: "Không thể xác nhận phiếu này."}
      return
    end

    if @voucher.voucher_medicines.size == 0
      render json: {code: 2, message: "Không thể xác nhận phiếu không có thuốc."}
      return
    end

    if @voucher.update_attributes status: :accepted
      if @voucher.typee == "import_from_allocation_agency"
        @voucher.voucher_medicines.each do |voucher_medicine|
          medicine = voucher_medicine.medicine
          medicine.update_attributes remaining_number: (medicine.remaining_number + voucher_medicine.number)
        end

        # Tru thuoc o kho cap phat
        @sub_voucher = SubVoucher.where(voucher_id: @voucher.id).first

        sub_medicines = @sub_voucher.sub_medicines
        total_number = 0
        if sub_medicines.length > 0
          sub_medicines.each do |sub_medicine|

            sub_voucher_sub_medicine = SubVoucherSubMedicine.where(sub_medicine_id: sub_medicine.id,
                                                                   sub_voucher_id: @sub_voucher.id).first

            if sub_voucher_sub_medicine.present?

              sub_medicine.update_attributes remaining: (sub_medicine.remaining - sub_voucher_sub_medicine.number),
                                             booking: (sub_medicine.booking - sub_voucher_sub_medicine.number)
            else
              render json: {code: 2, message: "Không tìm thấy thuốc này. Vui lòng F5 và tạo lại phiếu."}
              return
            end
          end
        else
          render json: {code: 2, message: "Không thể xác nhận phiếu không có thuốc."}
          return
        end
        @sub_voucher.update_attributes status: SubVoucher.statuses[:accepted]

      elsif @voucher.typee == "import_from_distributor"
        @voucher.medicines.update_all init_date: @voucher.datee, status: 1 # accepted
        @voucher.voucher_medicines.each do |voucher_medicine|
          update_inventory "import", @voucher.datee.to_date.strftime, @voucher.issuing_agency_id, voucher_medicine.number, voucher_medicine.medicine.id
        end

      elsif @voucher.typee == "import_end_day"
        @voucher.voucher_medicines.each do |voucher_medicine|
          # medicine = voucher_medicine.medicine
          origin_medicine = Medicine.find_by id: voucher_medicine.medicine.origin_medicine_id, origin_medicine_id: nil
          medicine = Medicine.find_by id: voucher_medicine.medicine.id
          if medicine.remaining_number < voucher_medicine.number
            render json: {code: 2, message: "Lượng thuốc trả lại lớn hơn thuốc đang còn"}
            return
          end
          origin_medicine.update_attributes remaining_number: (origin_medicine.remaining_number + voucher_medicine.number)
          medicine.update_attributes remaining_number: (medicine.remaining_number - voucher_medicine.number)
          update_inventory "import_end_day", @voucher.datee.to_date.strftime,
            @voucher.issuing_agency_id, voucher_medicine.number, origin_medicine.id
        end
      end
      render json: {code: 1, message: "Xác nhận thành công"}
    else
      render json: {code: 2, message: "Xác nhận thất bại"}
    end
  end
end
