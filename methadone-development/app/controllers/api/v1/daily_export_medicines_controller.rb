class Api::V1::DailyExportMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @medicines = Voucher.where(issuing_agency_id:
      @current_user.issuing_agency_id, type_ticket: 1)
  end

  def show
    @medicine = Voucher.find_by id: params[:id]
  end

  def create
    medicine = Voucher.new(medicine_params.merge(type_ticket: :export,
      issuing_agency_id: @current_user.issuing_agency_id, date_export: Time.now))
    if medicine.save
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  def update
    medicine = Voucher.find_by(id: params[:id])
    if medicine.update_attributes(medicine_params)
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Cập nhật thất bại"}
    end
  end

  def destroy
    medicine = Voucher.find_by(id: params[:id])
    if medicine.destroy
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def medicine_params
    params.require(:vouchers).permit :name, :composition, :concentration,
      :packing , :manufacturer, :provider, :source, :expiration_date,
      :production_batch, :remaining_number, :sender, :receiver, :type_export
  end
end
