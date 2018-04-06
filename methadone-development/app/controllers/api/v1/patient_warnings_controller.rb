class Api::V1::PatientWarningsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @patient_warnings = PatientWarning.pluck(:patient_id)
    @patients = Patient.not_deleted.select(:id, :name, :mobile_phone, :card_number,
     :identification_number, :gender, :birthdate, :admission_date, :address)
      .where(id: @patient_warnings, issuing_agency_id: @current_user.issuing_agency_id)
      .search(name_or_card_number_cont: params[:keyword]).result
      .paginate :page => params[:page], :per_page => Settings.per_page
    render json: {data: @patients, per_page: Settings.per_page,
      page: params[:page], total: @patients.total_entries, message: t("common.success")}
  end

  def show
    patient_warnings = PatientWarning.where(patient_id: params[:id]).last
    render json: {code: 1, data: patient_warnings}
  end

  def update
    patient_warning = PatientWarning.find_by id: params[:id]
    patient_warning.update_attributes(status: :close)
    render json: {code: 1, message: t("common.success")}
  end
end
