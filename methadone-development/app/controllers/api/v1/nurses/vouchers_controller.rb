class Api::V1::Nurses::VouchersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    time_now = Date.today
    medicine_allocations = Prescription.open.joins(:user)
                              .where("DATE(end_date) >= ? and users.issuing_agency_id = ?",
                                time_now, @current_user.issuing_agency_id)
                              .sum(:dosage)
    if Medicine.where(issuing_agency_id: @current_user.issuing_agency_id).size > 0 &&
      medicine_allocations > 0
      daily_import = Voucher.where(typee: 6,
          issuing_agency_id: @current_user.issuing_agency_id)
        .where("DATE(datee) = ?", time_now).last
      unless daily_import.present?

        daily_export = Voucher.new(status: 0, typee: 7, datee: Time.now,
          issuing_agency_id: @current_user.issuing_agency_id)
        daily_export.save(validate: false)
        daily_import = Voucher.new(status: 0, typee: 6, datee: Time.now,
          issuing_agency_id: @current_user.issuing_agency_id)
        daily_import.save(validate: false)
        medicines = Medicine.where(issuing_agency_id: @current_user.issuing_agency_id)
          .where("remaining_number > 0 and DATE(expiration_date) >= ?", Date.today)
          .order(expiration_date: :asc)
        value = medicine_allocations
        medicines.each do |medicine|
          if medicine.remaining_number < value
            VoucherMedicine.new(voucher_id: daily_export.id,
              medicine_id: medicine.id, number: medicine.remaining_number).save(validate: false)
            value -= medicine.remaining_number
          elsif value > 0
            VoucherMedicine.new(voucher_id: daily_export.id,
              medicine_id: medicine.id, number: value).save(validate: false)
            tmp = medicine.remaining_number - value
            value = 0
          end
        end
      end

      if params[:type] == 'import'
        @vouchers = Voucher.nurse_import
          .where(issuing_agency_id: @current_user.issuing_agency_id)
          .where("DATE(datee) = ?", time_now).last
        unless @vouchers.present?
          @vouchers = Voucher.new(status: 0, typee: 6,
            datee: Time.now,
            issuing_agency_id: @current_user.issuing_agency_id)
          @vouchers.save(validate: false)
        end
      else
        @vouchers = Voucher.nurse_export
          .where(issuing_agency_id: @current_user.issuing_agency_id)
          .where("DATE(datee) = ?", time_now).last
      end
    end
    if !@vouchers
      render json: {code: 1, data: {}}
    end
  end

  def update
    vouchers = Voucher.find_by id: params[:id]
    if vouchers.present?
      vouchers.voucher_medicines.each do |voucher|
        number_medicine = voucher.medicine.remaining_number - voucher.number
        voucher.medicine.update_columns(remaining_number: number_medicine)
      end
      vouchers.update_columns(status: 1)
      render json: {code: 1, message: "Xác nhận thành công"}
    else
      render json: {code: 1, message: "Phiếu hàng không tồn tại"}
    end
  end
end
