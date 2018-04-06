class Api::V1::Admin::ManufacturersController < ApplicationController
  before_action :authenticate_request!
  before_action :find_manufacturer, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    manufacturers = Manufacturer.all.search(name_cont: params[:keyword], status_eq: Manufacturer.statuses[params[:keystatus]])
      .result.paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, data: manufacturers, per_page: Settings.per_page,
      page: params[:page], total: manufacturers.total_entries, message: "success"}
  end

  def show
    render json: {code: 1, data: @manufacturer, message: "success"}
  end

  def create
    check_exist = Manufacturer.where(name: params[:manufacturer][:name])
    if check_exist.blank?
      manufacturer = Manufacturer.new manufacturer_params
      if manufacturer.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.manufacturer_create_exist")}
    end
  end

  def update
    check_exist = Manufacturer.where(name: params[:manufacturer][:name])
      .where(status: Manufacturer.statuses[params[:manufacturer][:status]])
    if check_exist.blank?
      if @manufacturer.update_attributes manufacturer_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else

      render json: {code: 2, message: t("admin.category.manufacturer_create_exist")}
    end
  end

  def destroy
    check_exist = MedicineList.where(manufacturer: @manufacturer.name)
    if check_exist.present?
      if params[:deactived]  == "1"
        if @manufacturer.update_attributes(status: Manufacturer.statuses[:deactived])
          render json: {code: 1, message: "Tạm dừng thành công"}
        else
          render json: {code: 2, message: "Tạm dừng thất bại"}
        end
      else
        render json: {code: 3, status: "instock"}
      end
    else
      if @manufacturer.destroy
        render json: {code: 1, message: t("admin.category.delete_success")}
      else
        render json: {code: 2, message: t("admin.category.delete_fail")}
      end
    end
  end

  def get_all
    manufacturers = Manufacturer.all
    render json: {data: manufacturers, message: "success"}
  end

  private

  def manufacturer_params
    params.require(:manufacturer).permit :name, :status
  end

  def find_manufacturer
    @manufacturer = Manufacturer.find_by_id (params[:id])
  end
end
