class Api::V1::Admin::StopReasonsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_reason, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token
  respond_to :json
  def index
    reasons = StopReason.search(name_cont: params[:keyword], status_eq: StopReason.statuses[params[:keystatus]])
      .result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: reasons, per_page: Settings.per_page,
      page: params[:page], total: reasons.total_entries, message: "success"}
  end

  def show
    render json: {code: 1, data: @reason, message: "success"}
  end

  def create
    check_exist = StopReason.where(name: params[:reason][:name])
    if check_exist.blank?
      reason = StopReason.new reason_params
      if reason.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.reason_create_exist")}
    end
  end

  def update
    check_exist = StopReason.where(name: params[:reason][:name])
      .where(status: StopReason.statuses[params[:reason][:status]])
    if check_exist.blank?
      if @reason.update_attributes reason_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.reason_create_exist")}
    end
  end

  def destroy
    if @reason.update_attributes(status: StopReason.statuses[:deactived])
      render json: {code: 1, message: t("admin.category.delete_success")}
    else
      render json: {code: 2, message: t("admin.category.delete_fail")}
    end
  end

  def get_all
    reasons = StopReason.actived
    render json: {code: 1, data: reasons, message: "success"}
  end

  private

  def reason_params
    params.require(:reason).permit(:name, :status)
  end

  def find_reason
    @reason = StopReason.find_by id: params[:id]
  end

end
