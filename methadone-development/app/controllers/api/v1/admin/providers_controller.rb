class Api::V1::Admin::ProvidersController < ApplicationController
  before_action :authenticate_request!
  before_action :find_provider, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    providers = Provider.search(name_cont: params[:keyword], status_eq: Provider.statuses[params[:keystatus]])
      .result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: providers, per_page: Settings.per_page,
      page: params[:page], total: providers.total_entries, message: "success"}
  end

  def show
    render json: {code: 1, data: @provider, message: "success"}
  end

  def create
    check_exist = Provider.where(name: params[:provider][:name])
    if check_exist.blank?
      provider = Provider.new provider_params
      if provider.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.provider_create_exist")}
    end
  end

  def update
    check_exist = Provider.where(name: params[:provider][:name])
      .where(status: Provider.statuses[params[:provider][:status]])
    if check_exist.blank?
      if @provider.update_attributes provider_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.provider_create_exist")}
    end
  end

  def destroy
    check_exist = MedicineList.where(provider: @provider.name)
    if check_exist.present?
      if params[:deactived]  == "1"
        if @provider.update_attributes(status: Provider.statuses[:deactived])
          render json: {code: 1, message: "Tạm dừng thành công"}
        else
          render json: {code: 2, message: "Tạm dừng thất bại"}
        end
      else
        render json: {code: 3, status: "instock"}
      end
    else
      if @provider.destroy
        render json: {code: 1, message: t("abc")}
      else
        render json: {code: 2, message: t("abc")}
      end
    end
  end

  def get_all
    providers = Provider.all
    render json: {code: 1, data: providers, message: "success"}
  end

  private

  def provider_params
    params.require(:provider).permit :name, :status
  end

  def find_provider
    @provider = Provider.find_by_id (params[:id])
  end
end
