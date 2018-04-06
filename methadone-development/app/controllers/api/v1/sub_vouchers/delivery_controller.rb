class Api::V1::SubVouchers::DeliveryController < ApplicationController
  before_action :authenticate_request!
  before_action :find_sub_voucher, only: [:update]
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    type = [0,1]
    @sub_vouchers = SubVoucher.where(issuing_agency_id: @current_user.issuing_agency_id)
                              .where(typee: type)
                              .order('id DESC')
                              .ransack(code_or_sender_or_receiver_cont: params[:keyword]).result
  end

  def search_sub_voucher
    type = params[:sub_voucher][:typee].present? ? [SubVoucher.typees[params[:sub_voucher][:typee].to_sym]] : [0, 1]
    status = params[:sub_voucher][:status].present? ? params[:sub_voucher][:status].to_sym : nil
    date_start = params[:sub_voucher][:date_end].to_date rescue nil
    date_end = params[:sub_voucher][:date_start].to_date rescue nil
    sender = params[:sub_voucher][:sender].present? ? params[:sub_voucher][:sender].to_sym : nil
    receiver = params[:sub_voucher][:receiver].present? ? params[:sub_voucher][:receiver].to_sym : nil
    code = params[:sub_voucher][:code].present? ? params[:sub_voucher][:code].gsub(" ", "") : nil
    @sub_vouchers = SubVoucher.order(created_at: :desc)
                        .where(issuing_agency_id: @current_user.issuing_agency_id)
                        .ransack(code_cont: code,
                          sender_cont: sender,
                          receiver_cont: receiver,
                          typee_in: type,
                          datee_lteq: date_start,
                          datee_gteq: date_end,
                          status_eq: SubVoucher.statuses[status]).result
  end

  def show
    @sub_voucher = SubVoucher.find_by_id(params[:id])
    @sub_medicines = @sub_voucher.sub_medicines
  end

  def destroy
    sub_voucher = SubVoucher.find_by_id (params[:id])

    if sub_voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã xác nhận không thể xóa."}
      return
    end

    sub_medicines = sub_voucher.sub_medicines

    if sub_medicines.length > 0
      sub_medicines.each do |sub_medicine|

        sub_voucher_sub_medicine = SubVoucherSubMedicine.where(sub_medicine_id: sub_medicine.id,
                                                               sub_voucher_id: sub_voucher.id).first
        if sub_voucher_sub_medicine.present?
          sub_medicine.update_attributes booking: (sub_medicine.booking - sub_voucher_sub_medicine.number)
        else
          render json: {code: 2, message: "Không tìm thấy thuốc này. Vui lòng F5 và tạo lại phiếu."}
          return
        end
      end
    end
    if sub_voucher.destroy
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def sub_voucher_params
    params.require(:sub_voucher).permit :sender, :receiver, :agency_sender_receiver, :medicines
  end

  def find_sub_voucher
    @sub_voucher = SubVoucher.find_by_id(params[:id])
  end
end
