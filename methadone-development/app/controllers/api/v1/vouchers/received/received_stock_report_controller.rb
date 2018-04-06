class Api::V1::Vouchers::Received::ReceivedStockReportController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    date_start = params[:date_end].to_date rescue nil
    date_end = params[:date_start].to_date rescue nil
    provider_id = params[:provider] rescue nil
    @vouchers = Voucher.distinct(:id)
                        .select(:id, :invoice_number)
                        .where(issuing_agency_id: @current_user.issuing_agency_id,
                          typee: 4)
                        .ransack(
                          datee_lteq: date_start,
                          datee_gteq: date_end,
                          status_eq: Voucher.statuses[:accepted],
                          medicines_provider_id_eq: provider_id).result rescue []
    render json: {code: 1, data: @vouchers}
  end

  def show
    issuing_agency_id = @current_user.issuing_agency_id
    date_start = params[:date_start].to_date rescue nil
    date_end = params[:date_end].to_date rescue nil
    provider_id = params[:provider].present? ? params[:provider]: nil
    invoice_number = params[:invoice_number].present? ? params[:invoice_number] : nil

    @medicines = Voucher.all_medicine(issuing_agency_id, date_start, date_end, provider_id,
      invoice_number)

    # render json: {code: 1, data: @medicines}
  end
end
