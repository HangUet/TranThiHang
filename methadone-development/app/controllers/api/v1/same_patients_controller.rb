class Api::V1::SamePatientsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    roles = [1, 2, 4] #bác sĩ, trưởng cơ sở, hành chính
    receivers = User.where(role: roles).where(issuing_agency_id: params[:receive_agency_id])
    @patient_agency_history = PatientAgencyHistory.create status: :pending,
      sender_id: @current_user.id, sender_agency_id: @current_user.issuing_agency.id,
      patient_id: params[:patient_id], receiver_agency_id: params[:receive_agency_id]
    Notification.bulk_insert(ignore: true) do |worker|
      receivers.each do |receiver|
        worker.add({content: "Yêu cầu chuyển cơ sở với bệnh nhân trùng.",
          url: "main/same_patient/#{@patient_agency_history.id}", user_id: receiver.id})
      end
    end
    render json: {code: 1, data: "", message: "Đã gửi yêu cầu chuyển cơ sở, vui lòng chờ xác nhận"}
  end

  def feedback
    @patient_agency_history = PatientAgencyHistory.find_by_id params[:id]
    if @patient_agency_history.present?
      @patient_agency_history.update status: params[:status], confirmer_id: @current_user.id
      if params[:status] == "accepted"
        @patient_agency_history.patient.update issuing_agency_id: params[:sender_agency_id]
        @patient_agency_history.update date_accepted: Date.today
      end
      Notification.create content: "Phản hồi yêu cầu chuyển cơ sở.",
        url: "main/same_patient/#{@patient_agency_history.id}", user_id: @patient_agency_history.sender_id
      render json: {data: @patient_agency_history, code: 1, message: "Thành công"}
    else
      render json: {code: 2, message: "Yêu cầu chuyển cơ sở này đã bị hủy"}
    end
  end
end
