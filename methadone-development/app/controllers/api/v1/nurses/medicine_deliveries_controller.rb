class Api::V1::Nurses::MedicineDeliveriesController < ApplicationController
  before_action :authenticate_request!
  before_action :init_medicine_voucher, only: [:show, :update, :destroy]
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def index
    time_now = Date.today
    vouchers = Voucher.nurse_export
      .where(issuing_agency_id: @current_user.issuing_agency_id)
      .where("DATE(datee) = ?", time_now).last
    if vouchers.present?
      @voucher_medicines = VoucherMedicine
        .where(voucher_id: vouchers.id)
    else
      render json: {code: 1, data: []}
    end
  end
end
