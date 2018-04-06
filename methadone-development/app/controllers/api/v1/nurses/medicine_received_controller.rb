class Api::V1::Nurses::MedicineReceivedController < ApplicationController
  before_action :authenticate_request!
  before_action :init_medicine_voucher, only: [:show, :update, :destroy]
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def index
    time_now = Date.today
    vouchers = Voucher.nurse_import
      .where(issuing_agency_id: @current_user.issuing_agency_id)
      .where("DATE(datee) = ?", time_now).last
    if vouchers.present?
      @voucher_medicines = VoucherMedicine
        .where(voucher_id: vouchers.id)
    else
      render json: {code: 1, data: []}
    end
  end

  def create
    time_now = Date.today
    vouchers = Voucher.nurse_import
      .where(issuing_agency_id: @current_user.issuing_agency_id)
      .where("DATE(datee) = ?", time_now).last
    voucher_export = Voucher.nurse_export
        .where(issuing_agency_id: @current_user.issuing_agency_id)
        .where("DATE(datee) = ?", time_now).last
    voucher_medicines = params[:voucher_medicines]
    tmp = 0
    check = true
    voucher_medicines.each do |voucher_medicine|
      if voucher_medicine[:number].present? && voucher_medicine[:number] > 0 &&
        voucher_export.present?
        medicine = VoucherMedicine.find_by(medicine_id: voucher_medicine[:medicine_id],
          voucher_id: voucher_export.id)
      if medicine.number - voucher_medicine[:number] < 0
          check = false
          break
        end
      end
    end
    if check
      vouchers.update_columns(status: 1)
      voucher_medicines.each do |voucher_medicine|
        if voucher_medicine[:number].present? && voucher_medicine[:number].to_i > 0
          voucher = vouchers.voucher_medicines.new(medicine_id: voucher_medicine[:medicine_id],
            number: voucher_medicine[:number])
          voucher.save(validate: false)
          number = voucher.medicine.remaining_number + voucher_medicine[:number]
          voucher.medicine.update_columns(remaining_number: number)
          tmp += 1
        end
      end
      if tmp > 0
        render json: {code: 1, message: "Xác nhận phiếu nhập kho thành công"}
      else
        render json: {code: 1, message: "Không có thuốc nhập vào"}
      end
    else
      render json: {code: 1, message: "Số lượng nhập vào không hợp lệ"}
    end

  end
end
