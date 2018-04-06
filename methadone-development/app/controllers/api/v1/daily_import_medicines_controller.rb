class Api::V1::DailyImportMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @medicines = Voucher.where(issuing_agency_id:
      @current_user.issuing_agency_id, type_ticket: 0)
  end

  def create
    medicine = Voucher.new(medicine_params.merge(type_ticket: :import,
      issuing_agency_id: @current_user.issuing_agency_id, date_export: Time.now))
    if medicine.save
      Medicine.create(medicine_params.merge(import_id: medicine.id).except(:sender, :receiver, :type_export))
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  def import_export_day
    @issuing_agency_id = @current_user.issuing_agency_id
    if params[:date]
      @day = params[:date].split("/")[0]
      @month = params[:date].split("/")[1]
      @year = params[:date].split("/")[2]
      init_ie(@day, @month, @year, @issuing_agency_id)
    else
      init_ie(Time.now.day, Time.now.month, Time.now.year, @issuing_agency_id)
    end
  end

  def show
    @medicine = Voucher.find_by(id: params[:id])
  end

  def update
    medicine = Voucher.find_by(id: params[:id])
    import = Medicine.find_by(import_id: params[:id])
    if medicine.update_attributes(medicine_params)
      import.update_attributes(medicine_params.except(:sender, :receiver, :type_export))
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Cập nhật thất bại"}
    end
  end

  def destroy
    medicine = Voucher.find_by(id: params[:id])
    import = Medicine.find_by(import_id: params[:id])
    if medicine.destroy
      import.destroy
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  def get_store_report
    if params[:month]
      month = params[:month].split("/")[0].to_i
      year = params[:month].split("/")[1].to_i
    else
      month = Time.now.month
      year = Time.now.year
    end

    @reports = Voucher.get_report_store(month, year, @current_user.issuing_agency_id)
    @total_patients = Patient.not_deleted.where(issuing_agency_id: @current_user.issuing_agency_id).size
  end

  private

  def medicine_params
    params.require(:vouchers).permit :name, :composition, :concentration,
      :packing , :manufacturer, :provider, :source, :expiration_date,
      :production_batch, :remaining_number, :sender, :receiver, :type_export
  end

  def init_ie(day, month, year, issuing_agency_id)
    @import_exports = VoucherMedicine.day_import_export(day, month, year, 0, 2, issuing_agency_id)
    @other_sources = VoucherMedicine.day_import_export(day, month, year, 1, 3, issuing_agency_id)
    @allocation = MedicineAllocation.sum_allocation(day, month, year, issuing_agency_id)
    @import = VoucherMedicine.total_day_ie(day, month, year, 2, issuing_agency_id)
    @export = VoucherMedicine.total_day_ie(day, month, year, 0, issuing_agency_id)
    @import_other = VoucherMedicine.total_day_ie(day, month, year, 3, issuing_agency_id)
    @export_other = VoucherMedicine.total_day_ie(day, month, year, 1, issuing_agency_id)
    @used = @export[0].sum && @import[0].sum ? @export[0].sum - @import[0].sum : nil
  end
end
