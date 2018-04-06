class Api::V1::SubVouchers::Received::AcceptController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def update

    # Tim phieu nhap cuoi ngay
    # Kiem tra phieu chua xac nhan va ton tai
    # Cap nhat booking vaf remaining cua day_medicine
    # Cap nhat remaining cua sub_medicine
    # Cap nhat trang thai cua phieu

    sub_voucher = SubVoucher.find_by_id (params[:id])

    unless sub_voucher.present?
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end

    if sub_voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã xác nhận không thể xóa."}
      return
    end

    sub_voucher_sub_medicines = sub_voucher.sub_voucher_sub_medicines

    # CHECK THUOC LOI. TOI UU SAU

    sub_voucher_sub_medicines.each do |sub_voucher_sub_medicine|

      day_medicine = DayMedicine.where(id: sub_voucher_sub_medicine.day_medicine_id).first
      sub_medicine = SubMedicine.where(id: sub_voucher_sub_medicine.sub_medicine_id).first

      if day_medicine.present? && sub_medicine.present?
      else
        render json: {code: 2, message: "Không tìm thấy thuốc. Vui lòng F5 và tạo lại phiếu."}
        return
      end
    end

    # -------------------------
    total_number = sub_voucher.sub_voucher_sub_medicines.sum(:number)
    sub_voucher_sub_medicines.each do |sub_voucher_sub_medicine|

      day_medicine = DayMedicine.where(id: sub_voucher_sub_medicine.day_medicine_id).first
      sub_medicine = SubMedicine.where(id: sub_voucher_sub_medicine.sub_medicine_id).first

      if day_medicine.present? && sub_medicine.present?
        day_medicine.update_attributes booking: day_medicine.booking - sub_voucher_sub_medicine.number,
                                       remaining: day_medicine.remaining - sub_voucher_sub_medicine.number
        sub_medicine.update_attributes remaining: (sub_medicine.remaining + sub_voucher_sub_medicine.number)
      else
        render json: {code: 2, message: "Không tìm thấy thuốc. Vui lòng F5 và tạo lại phiếu."}
        return
      end

      # # cap nhap sub_inventory
      # update_sub_inventory "export", sub_voucher.datee.to_date.strftime,
      #   sub_voucher.issuing_agency_id, total_number, sub_voucher_sub_medicine.sub_medicine.medicine.id
      # # cap nhap inventory
      # update_inventory "import_day", sub_voucher.datee.to_date.strftime,
      #   sub_voucher.issuing_agency_id, sub_voucher_sub_medicine.number, sub_voucher_sub_medicine.sub_medicine.medicine.id
    end
    sub_voucher.update_attributes status: 1 # accepted
    render json: {code: 1, message: "Cập nhật thành công."}
    return
  end
end
