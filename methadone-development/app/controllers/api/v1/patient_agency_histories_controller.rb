class Api::V1::PatientAgencyHistoriesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @patient_agency_histories = PatientAgencyHistory.accepted.where(patient_id: params[:patient_id])
  end

  def create
    if patient_agency_history[:receiver_agency_id] == @current_user.issuing_agency.id
      render json: {code: 2, message: "Không được phép chuyển đến cơ sở hiện tại của bệnh nhân."}
      return
    end
    @patient = Patient.find_by_id patient_agency_history[:patient_id]
    if @patient.patient_agency_histories.pending.count > 0
      render json: {code: 2, message: "Bệnh nhân đang chờ chuyển cơ sở."}
      return
    end
    @patient_agency_history = PatientAgencyHistory.new patient_agency_history
    @patient_agency_history.assign_attributes(status: :pending, sender_id: @current_user.id, sender_agency_id: @current_user.issuing_agency.id)
    @patient_agency_history.save
    roles = [1, 2, 4] #bác sĩ, trưởng cơ sở, hành chính
    receivers = User.where(role: roles).where(issuing_agency_id: patient_agency_history[:receiver_agency_id])
    Notification.bulk_insert(ignore: true) do |worker|
      receivers.each do |receiver|
        if params[:end_date]
          worker.add({content: "Yêu cầu chuyển cơ sở tạm thời.", url: "main/patient_agency_histories/#{@patient_agency_history.id}", user_id: receiver.id})
        else
          worker.add({content: "Yêu cầu chuyển cơ sở.", url: "main/patient_agency_histories/#{@patient_agency_history.id}", user_id: receiver.id})
        end
      end
    end
    if params[:end_date]
      @message = "Chuyển tạm thời thành công. Vui lòng chờ xác nhận."
    else
      @message = "Chuyển thành công. Vui lòng chờ xác nhận."
    end
    render json: {data: @patient_agency_history, code: 1, message: @message}
  end

  def show
    @patient_agency_history = PatientAgencyHistory.find_by_id params[:id]
  end

  def feedback
    @patient_agency_history = PatientAgencyHistory.find_by_id params[:id]
    if @patient_agency_history.present?
      if @patient_agency_history.status != "pending"
        render json: {code: 2, message: "Yêu cầu chuyển cơ sở này không còn hiệu lực, vui lòng F5 trình duyệt"}
      else
        @patient_agency_history.update status: params[:status], confirmer_id: @current_user.id
        if params[:status] == "accepted"
          @patient_agency_history.patient.update issuing_agency_id: @current_user.issuing_agency_id
          @patient_agency_history.update date_accepted: Date.today
        end
        Notification.create content: "Phản hồi yêu cầu chuyển cơ sở.",
          url: "main/patient_agency_histories/#{@patient_agency_history.id}", user_id: @patient_agency_history.sender_id
        render json: {data: @patient_agency_history, code: 1, message: "Thành công"}
      end
    else
      render json: {code: 2, message: "Yêu cầu chuyển cơ sở này đã bị hủy"}
    end
  end

  def destroy
    @patient_agency_history = PatientAgencyHistory.pending.find_by patient_id: params[:id]
    @receiver_doctors = User.doctor.where(issuing_agency_id: @patient_agency_history.receiver_agency_id)
    @receiver_doctors.each do |doctor|
      @notification = Notification.find_by user_id: doctor.id
      @notification.destroy
    end
    if @patient_agency_history.destroy
      render json: {code: 1, message: "Hủy chuyển cơ sở thành công"}
    else
      render json: {code: 2, message: "Hủy chuyển cơ sở thất bại"}
    end
  end

  def patient_agency_history
    params.require(:patient_agency_history).permit :patient_id, :receiver_agency_id, :end_date
  end
end
