class Api::V1::Vouchers::Delivery::AcceptController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def update

    # Tim phieu nhap cuoi ngay
    # Kiem tra phieu chua xac nhan va ton tai

    @voucher = Voucher.find_by(id: params[:id])

    if @voucher.nil?
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end

    if @voucher.user_id != current_user.id
      render json: {code: 2, message: "Không thể xác nhận phiếu này."}
      return
    end

    if @voucher.voucher_medicines.size == 0
      render json: {code: 2, message: "Không thể xác nhận phiếu không có thuốc."}
      return
    end

    if @voucher.accepted?
      render json: {code: 2, message: "Phiếu đã xác nhận, không thể xác nhận lại."}
      return
    end

    # thuc hien xac nhan
    if @voucher.update_attributes status: :accepted
      if @voucher.typee == "export_allocation"

        # total_number = @voucher.voucher_medicines.sum(:number)
        @voucher.voucher_medicines.each do |voucher_medicine|
          medicine = voucher_medicine.medicine
          medicine.update_attributes booking: medicine.booking - voucher_medicine.number,
                                     remaining_number: medicine.remaining_number - voucher_medicine.number

          new_medicine = Medicine.create issuing_agency_id: @current_user.issuing_agency_id,
                                         expiration_date: medicine.expiration_date,
                                         production_batch: medicine.production_batch,
                                         remaining_number: voucher_medicine.number,
                                         medicine_list_id: medicine.medicine_list_id,
                                         provider_id: medicine.provider_id,
                                         source: medicine.source,
                                         price: medicine.price,
                                         status: :accepted,
                                         division: :allocation,
                                         origin_medicine_id: medicine.id,
                                         init_date: @voucher.datee

          # cap nhap sub_inventory
          # update_sub_inventory "import", @voucher.datee.to_date.strftime,
          #   @voucher.issuing_agency_id, total_number, voucher_medicine.medicine.id
          update_inventory "export_allocate", @voucher.datee.to_date.strftime, @voucher.issuing_agency_id, voucher_medicine.number, medicine.id
        end

      elsif @voucher.typee == "export_destroy"
        @voucher.voucher_medicines.each do |voucher_medicine|
          medicine = voucher_medicine.medicine
          medicine.update_attributes booking: medicine.booking - voucher_medicine.number,
                                     remaining_number: medicine.remaining_number - voucher_medicine.number
          update_inventory "export", @voucher.datee.to_date.strftime, @voucher.issuing_agency_id, voucher_medicine.number, voucher_medicine.medicine.id
        end
      end
      render json: {code: 1, message: "Xác nhận thành công"}
    else
      render json: {code: 2, message: "Xác nhận thất bại"}
    end
  end
end
