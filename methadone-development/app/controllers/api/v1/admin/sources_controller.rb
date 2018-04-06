class Api::V1::Admin::SourcesController < ApplicationController
  before_action :authenticate_request!
  before_action :find_source, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    sources = Source.search(name_cont: params[:keyword], status_eq: Source.statuses[params[:keystatus]]).
      result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: sources, per_page: Settings.per_page,
      page: params[:page], total: sources.total_entries, message: t("common.success")}
  end

  def show
    render json: {code: 1, data: @source, message: t("common.success")}
  end

  def create
    check_exist = Source.where(name: params[:source][:name])
    if check_exist.blank?
      source = Source.new source_params
      if source.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.source_create_exist")}
    end
  end

  def update
    check_exist = Source.where(name: params[:source][:name])
      .where(status: Source.statuses[params[:source][:status]])
    if check_exist.blank?
      if @source.update_attributes source_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.source_create_exist")}
    end
  end

  def destroy
     if @source.update_attributes(status: Source.statuses[:deactived])
      render json: {code: 1, message: t("admin.category.delete_success")}
    else
      render json: {code: 2, message: t("admin.category.delete_fail")}
    end
  end

  private

  def source_params
    params.require(:source).permit(:name, :status)
  end

  def find_source
    @source = Source.find_by id: params[:id]
    render json: {code: 2, message: t("admin.category.not_found")} unless @source
  end
end
