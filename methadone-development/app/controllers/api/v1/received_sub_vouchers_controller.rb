class Api::V1::ReceivedSubVouchersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @received_sub_vouchers = SubVoucher.where(issuing_agency_id: @current_user.issuing_agency_id)
      .where(typee: SubVoucher.typees[:import_end_day])
    # render json: {data: @received_sub_vouchers, code: 1, mesage: "success"Ư
  end

  def create
    sub_voucher = SubVoucher.new(sub_voucher_params.merge(datee: Time.now, status: :pending,
      issuing_agency_id: current_user.issuing_agency_id))
    if sub_voucher.save
      params[:sub_voucher][:sub_medicines].each do |sub_medicine|
        new_sub_medicine = SubMedicine.create!(remaining: sub_medicine[:remaining], medicine_id: sub_medicine[:id],
          issuing_agency_id: @current_user.issuing_agency_id)
        SubVoucherSubMedicine.create!(sub_medicine_id: new_sub_medicine.id, sub_voucher_id: sub_voucher.id,
          number: sub_medicine[:number])
      end
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  def destroy
    @sub_voucher = SubVoucher.find_by_id (params[:id])
    if @sub_voucher.destroy && SubVoucherSubMedicine.where(sub_voucher_id: params[:id]).destroy_all
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def sub_voucher_params
    params.require(:sub_voucher).permit :status, :typee, :datee, :issuing_agency_id, :sender, :receiver
  end

end
