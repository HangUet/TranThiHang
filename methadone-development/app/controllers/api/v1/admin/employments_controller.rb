class Api::V1::Admin::EmploymentsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_employment, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    employments = Employment.search(name_cont: params[:keyword], status_eq: Employment.statuses[params[:keystatus]]).
      result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: employments, per_page: Settings.per_page,
      page: params[:page], total: employments.total_entries, message: t("common.success")}
  end

  def show
    render json: {code: 1, data: @employment, message: t("common.success")}
  end

  def create
    check_exist = Employment.where(name: params[:employment][:name])
    if check_exist.blank?
      employment = Employment.new employment_params
      if employment.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.employment_create_exist")}
    end
  end

  def update
    check_exist = Employment.where(name: params[:employment][:name])
      .where(status: Employment.statuses[params[:employment][:status]])
    if check_exist.blank?
      if @employment.update_attributes employment_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.employment_create_exist")}
    end
  end

  def destroy
     if @employment.update_attributes(status: Employment.statuses[:deactived])
      render json: {code: 1, message: t("admin.category.delete_success")}
    else
      render json: {code: 2, message: t("admin.category.delete_fail")}
    end
  end

  private

  def employment_params
    params.require(:employment).permit(:name, :status)
  end

  def find_employment
    @employment = Employment.find_by id: params[:id]
    render json: {code: 2, message: t("admin.category.not_found")} unless @employment
  end
end
