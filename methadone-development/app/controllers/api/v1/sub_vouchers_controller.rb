class Api::V1::SubVouchersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @sub_vouchers = SubVoucher.where(issuing_agency_id: @current_user.issuing_agency_id)
  end

  def show
    @sub_voucher = SubVoucher.find_by(id: params[:id])
  end

  def create
    sub_voucher = SubVoucher.new(sub_voucher_params.merge(datee: Time.now, status: :pending,
      issuing_agency_id: current_user.issuing_agency_id))
    if sub_voucher.save
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  def update
  end

  def destroy

  end

  private

  def sub_voucher_params
    params.require(:sub_voucher).permit :status, :typee, :datee, :issuing_agency_id, :sender, :receiver
  end

end
