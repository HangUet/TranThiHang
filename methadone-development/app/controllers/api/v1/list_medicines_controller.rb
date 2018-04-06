class Api::V1::ListMedicinesController < ApplicationController
  before_action :authenticate_request!
  before_action :find_medicine_list, only: [:update, :destroy, :show]
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @medicines = MedicineList.search(name_or_composition_cont: params[:keyword], status_eq: MedicineList.statuses[params[:keystatus]]).
      result.paginate page: params[:page], per_page: Settings.per_page
  end

  def show
    render json: {code: 1, data: @medicine_list, message: "success"}
  end

  def create
    check_exist = MedicineList.where(name: params[:medicine_list][:name],
      composition: params[:medicine_list][:composition],
      concentration: params[:medicine_list][:concentration],
      packing: params[:medicine_list][:packing],
      manufacturer: params[:medicine_list][:manufacturer],
      medicine_type_id: params[:medicine_list][:medicine_type_id])
    if check_exist.empty?
      @medicine_list = MedicineList.new medicine_list_params
      if @medicine_list.save
        render json: {code: 1, message: "Tạo danh mục thành công"}
      else
        render json: {code: 2, message: "Có lỗi xảy ra"}
      end
    else
      render json: {code: 2, message: "Danh mục thuốc đã tồn tại"}
    end
  end

  def update
    check_exist = MedicineList.where(name: params[:medicine_list][:name],
      composition: params[:medicine_list][:composition],
      concentration: params[:medicine_list][:concentration],
      packing: params[:medicine_list][:packing],
      manufacturer: params[:medicine_list][:manufacturer],
      status: params[:medicine_list][:status],
      medicine_type_id: params[:medicine_list][:medicine_type_id])
    if params[:medicine_list][:status] == "actived"
      check_exist = check_exist.where(status: MedicineList.statuses[:actived])
    else
      check_exist = check_exist.where(status: MedicineList.statuses[:deactived])
    end
    if check_exist.empty?
      if @medicine_list.medicines.blank? || params[:medicine_list][:status]  == "actived"
        if @medicine_list.update_attributes medicine_list_params
          render json: {code: 1, message: t("admin.category.update_success")}
        else
          render json: {code: 2, message: t("admin.category.update_fail")}
        end
      else
        if params[:confirm_deactived]  == 1
          if @medicine_list.update_attributes(status: MedicineList.statuses[:deactived])
            render json: {code: 1, message: "Tạm dừng thành công"}
          else
            render json: {code: 2, message: "Tạm dừng thất bại"}
          end
        else
          render json: {code: 3, status: "instock"}
        end
      end
    else
      render json: {code: 2, message: "Danh mục thuốc đã tồn tại"}
    end
  end

  def destroy
    if !@medicine_list.medicines.present?
      if @medicine_list.destroy
        render json: {code: 1, message: t("admin.category.delete_success")}
      else
        render json: {code: 2, message: t("admin.category.delete_fail")}
      end
    else
      if params[:deactived]  == "1"
        if @medicine_list.update_attributes(status: MedicineList.statuses[:deactived])
          render json: {code: 1, message: "Tạm dừng thành công"}
        else
          render json: {code: 2, message: "Tạm dừng thất bại"}
        end
      else
        render json: {code: 3, status: "instock"}
      end
    end
  end

  private

  def medicine_list_params
    params.require(:medicine_list).permit :name, :composition, :concentration,
      :packing, :manufacturer, :status, :unit, :medicine_type_id
  end

  def find_medicine_list
    @medicine_list = MedicineList.find_by id: params[:id]
  end

end
