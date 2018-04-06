class Api::V1::Vouchers::Received::RejectController < ApplicationController
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

    if @voucher.typee == "import_from_allocation_agency"
      # Reject phieu gui len
      sub_voucher = SubVoucher.where(voucher_id: @voucher.id).first

      if @voucher.destroy
        sub_voucher.update_attributes status: SubVoucher.statuses[:rejected]
        render json: {code: 1, message: "Từ chối thành công"}
      else
        render json: {code: 2, message: "Từ chối thất bại"}
      end
    end
  end
end
