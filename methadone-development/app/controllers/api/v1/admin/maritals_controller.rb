class Api::V1::Admin::MaritalsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_marital, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    maritals = Marital.search(name_cont: params[:keyword], status_eq: Marital.statuses[params[:keystatus]]).
      result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: maritals, per_page: Settings.per_page,
      page: params[:page], total: maritals.total_entries, message: t("common.success")}
  end

  def show
    render json: {code: 1, data: @marital, message: t("common.success")}
  end

  def create
    check_exist = Marital.where(name: params[:marital][:name])
    if check_exist.blank?
      marital = Marital.new marital_params
      if marital.save
        render json: {:code => 1, message: t("admin.category.create_success")}
      else
        render json: {:code => 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.marital_create_exist")}
    end
  end

  def update
    check_exist = Marital.where(name: params[:marital][:name])
      .where(status: Marital.statuses[params[:marital][:status]])
    if check_exist.blank?
      if @marital.update_attributes marital_params
        render json: {:code => 1, message: t("admin.category.update_success")}
      else
        render json: {:code => 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.marital_create_exist")}
    end
  end

  def destroy
    if @marital.update_attributes(status: Marital.statuses[:deactived])
      render json: {:code => 1, message: t("admin.category.delete_success")}
    else
      render json: {:code => 2, message: t("admin.category.delete_fail")}
    end
  end

  private

  def marital_params
    params.require(:marital).permit :name, :status
  end

  def find_marital
    @marital = Marital.find_by id: params[:id]
    render json: {:code => 2, message: t("admin.category.not_found")} unless @marital
  end
end
