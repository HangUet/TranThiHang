class Api::V1::Admin::FinancialsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_financial, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    financials = Financial.search(fromfinancial_lteq: params[:keyword], tofinancial_gteq: params[:keyword],
      status_eq: Financial.statuses[params[:keystatus]]).result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: financials, per_page: Settings.per_page,
      page: params[:page], total: financials.total_entries, message: t("common.success")}
  end

  def show
    render json: {code: 1, data: @financial, message: t("common.success")}
  end

  def create
    check_exist = Financial.where(fromfinancial: params[:financial][:fromfinancial],
      tofinancial: params[:financial][:tofinancial])
    if check_exist.blank?
      financial = Financial.new financial_params
      if financial.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
     end
    else
      render json: {code: 2, message: t("admin.category.financial_create_exist")}
    end
  end

  def update
    check_exist = Financial.where(fromfinancial: params[:financial][:fromfinancial],
      tofinancial: params[:financial][:tofinancial]).where(status: Financial.statuses[params[:financial][:status]])
    if check_exist.blank?
      if @financial.update_attributes financial_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.financial_create_exist")}
    end
  end

  def destroy
    if @financial.update_attributes(status: Financial.statuses[:deactived])
      render json: {code: 1, message: t("admin.category.cancel_success")}
    else
      render json: {code: 2, message: t("admin.category.cancel_fail")}
    end
  end

  private

  def financial_params
    params.require(:financial).permit(:fromfinancial, :tofinancial, :status)
  end

  def find_financial
    @financial = Financial.find_by id: params[:id]
    render json: {code: 2, message: t("admin.category.not_found")} unless @financial
  end
end
