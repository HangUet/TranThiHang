class Api::V1::MedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @today = Date.today
    if params[:type] == "availability"
      @medicines = Medicine.main.accepted.where("issuing_agency_id = ? and remaining_number > 0
        and DATE(expiration_date) >= ?",
        @current_user.issuing_agency_id, @today)
    elsif params[:type] == "all"
      @medicines = Medicine.main.accepted.where("issuing_agency_id = ?", @current_user.issuing_agency_id)
    elsif params[:type] == "expiration_date_medicine" #thuoc het han
      @medicines = Medicine.main.accepted.where(issuing_agency_id: @current_user.issuing_agency_id)
        .where("DATE(expiration_date) < ?", @today)
        .search(name: params[:keyword]).result
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:type] == "can_not_use" #thuoc su dung het
      @medicines = Medicine.main.accepted.where(issuing_agency_id: @current_user.issuing_agency_id)
        .where("DATE(expiration_date) >= ? and remaining_number = 0", @today)
        .search(name: params[:keyword]).result
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:type] == "expirated_soon"
      @medicines = Medicine.main.accepted.where(issuing_agency_id: @current_user.issuing_agency_id)
        .where("DATE(expiration_date) <= ? and DATE(expiration_date) >= ? and remaining_number <> 0", @today + 180.days, @today)
        .search(name: params[:keyword]).result
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:type] == "yesterday"
      @medicines = Inventory.joins(:medicine => :medicine_list)
        .select("medicine_lists.composition", "SUM(inventories.allocate) AS export_yesterday", "medicine_lists.unit")
        .group("medicine_lists.composition").where("DATE(datee) = ?", params[:keyword]).where(issuing_agency_id: @current_user.issuing_agency_id)
      render json: {code: 1, message: "Thành công", data: @medicines}
    else
      @medicines = Medicine.main.accepted.where(issuing_agency_id: @current_user.issuing_agency_id)
        .where("DATE(expiration_date) >= ? and remaining_number > 0", @today)
        .search(name: params[:keyword]).result
        .paginate page: params[:page], per_page: Settings.per_page
    end
  end

  def show
    @medicine = Medicine.accepted.find_by id: params[:id]
  end

  # def create
  #   medicine = Medicine.new medicine_params
  #   if medicine.save
  #     render json: {code: 1, message: t("medicine.create.success")}
  #   else
  #     render json: {code: 2, message: t("medicine.create.fails")}
  #   end
  # end

  # def update
  #   medicine = Medicine.find_by id: params[:id]
  #   if medicine.update_attributes(medicine_params)
  #     render json: {code: 1, message: "Cập nhật thành công"}
  #   else
  #     render json: {code: 2, message: "Cập nhật thất bại"}
  #   end
  # end

  # def destroy
  #   medicine = Medicine..find_by id: params[:id]
  #   if medicine.destroy
  #     render json: {code: 1, message: "Xóa thành công"}
  #   else
  #     render json: {code: 2, message: "Xóa thất bại"}
  #   end
  # end

  private

  def medicine_params
    params.require(:medicine).permit :name, :composition, :concentration,
      :packing , :manufacturer, :provider, :source, :expiration_date,
      :production_batch, :remaining_number
  end
end
