class Api::V1::StopTreatmentHistoriesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
  end

  def create
    if params[:patient_id]
      patient = Patient.find_by_id(params[:patient_id])
      if patient.update_attributes(active: "actived")
        StopTreatmentHistory.where(patient_id: params[:patient_id]).last.update_attributes(return_time: Date.today)
        render json: {code: 1, message: "Thao tác thành công"}
      else
        render json: {code: 2, message: "Thao tác không thành công"}
      end
    else
      patient = Patient.find_by_id(params[:stop_treatment][:patient_id])
      prescriptions = patient.prescriptions
      prescriptions.each do |prescription|
        prescription.update_attributes(close_status: "close")
      end
      if patient.actived?
        patient.update_attributes(active: "deactived")
        stop_treatment = StopTreatmentHistory.new stop_treatment_params.merge(user_id: @current_user.id,
          stop_time: Time.now)
        if stop_treatment.save
          render json: {code: 1, message: "Thao tác thành công"}
        else
          render json: {code: 2, message: "Thao tác không thành công"}
        end
      else
        render json: {code: 1, message: "Bệnh nhân đã dừng điều trị"}
      end
    end
  end

  def update
  end

  def stop_treatment_params
    params.require(:stop_treatment).permit :reason, :patient_id
  end
end
