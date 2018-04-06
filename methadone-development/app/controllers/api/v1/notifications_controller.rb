class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @notifications = Notification.where(user_id: @current_user.id).order("created_at DESC")
                                 .paginate :page => params[:page], :per_page => Settings.per_page
    @total_unseen = Notification.unseen.where(user_id: @current_user.id).count
  end

  def show
    notification = Notification.find_by_id params[:id]
    render json: {code: 1, data: notification}
  end

  def create
    check_vommited = MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:vomited])
      .where("patient_id = ? and DATE(allocation_date) = ? and vomited_allocation = 0", params[:notification][:patient_id], Date.today).last
    if check_vommited.present?
      render json: {code: 3, message: "Có một thông báo nôn chưa được bác sĩ xử lý"}
      return
    end
    if params[:notification][:notify_status] == "vomited_10_minute" ||
      params[:notification][:notify_status] == "vomited_30_minute"

      prescription = Prescription.where(patient_id: params[:notification][:patient_id])
      .where("prescription_type != 'temp_afternoon' and prescription_type != 'temp_morning' and prescription_type != 'temp_day'").last

      medicine_allocation = MedicineAllocation.find_by id: params[:medicine_allocation_id]

      prescription_of_this_alloction = medicine_allocation.prescription

      if prescription.id > prescription_of_this_alloction.id && prescription.begin_date.to_date <= Date.today
        render json: {code: 3, message: "Bác sĩ vừa tạo một đơn mới, yêu cầu bác sĩ đóng đơn đó trước khi tạo thông báo nôn"}
        return
      end

      patient = Patient.find_by(id: params[:notification][:patient_id])

      notification = Notification.new notification_params.merge(url: "#", user_id: prescription.user_id, content: "Bệnh nhân #{patient.name} bị nôn")

      medicine_allocation.update_attributes(notify_status: "vomited")
      if params[:type] == "morning"
        vomited_time = "morning"
      elsif params[:type] == "afternoon"
        vomited_time = "afternoon"
      elsif params[:type] == "day"
        vomited_time = "day"
      end


      if notification.save
        notification.update_attributes(url: "main/notify_falled_medicine/#{notification.id}?allocation=" + params[:medicine_allocation_id].to_s + "&patient=" + params[:notification][:patient_id].to_s + "&notify_status=" + params[:notification][:notify_status].to_s + "&dosage=" + medicine_allocation.dosage.to_s + "&prescription=" + prescription.id.to_s + "&vomited_time=" + vomited_time.to_s)
        render json: {code: 1, message: t("notification.create.success")}
      else
        render json: {code: 2, message: t("notification.create.fails")}
      end

    elsif params[:notification][:notify_status] == "falled"
      medicine_allocation = MedicineAllocation.find_by id: params[:medicine_allocation_id]
      medicine = medicine_allocation.medicine
      medicine_allocation.update_attributes(notify_status: params[:notification][:notify_status])
      medicine_allocation_new = MedicineAllocation.create patient_id: params[:notification][:patient_id],
        allocation_date: Time.now, user_id: @current_user.id,
        dosage: medicine_allocation.dosage, status: "waiting",
        typee: medicine_allocation.typee,
        prescription_id: medicine_allocation.prescription_id
      if medicine.present?
        concentration = medicine.medicine_list.concentration
        update_inventory "falled", medicine_allocation.allocation_date.to_date.strftime,
          current_user.issuing_agency_id, medicine_allocation.dosage/concentration, medicine.origin_medicine_id
      end
      render json: {code: 1, message: t("notification.create.success")}
    elsif params[:notification][:notify_status] == "empty_prescription"
      prescription = Prescription.where(patient_id: params[:notification][:patient_id])
      .where("prescription_type != 'temp_afternoon' and prescription_type != 'temp_morning' and prescription_type != 'temp_day'").last
      notification = Notification.new notification_params.merge(url: "#", user_id: prescription.user_id, content: "Có 1 bệnh nhân không có đơn thuốc")
      if notification.save
        notification.update_attributes(url: "main/notify_prescription/#{notification.id}?" + "patient_id=" + params[:notification][:patient_id].to_s + "&notify_status=" + params[:notification][:notify_status].to_s)
        render json: {code: 1, message: t("notification.create.success")}
      else
        render json: {code: 2, message: t("notification.create.fails")}
      end
    elsif params[:notification][:notify_status] == "expirate_prescription"
      prescription = Prescription.where(patient_id: params[:notification][:patient_id])
      .where("prescription_type != 'temp_afternoon' and prescription_type != 'temp_morning' and prescription_type != 'temp_day'").last
      notification = Notification.new notification_params.merge(url: "#", user_id: prescription.user_id, content: "Có 1 bệnh nhân hết hạn đơn thuốc")
      if notification.save
        notification.update_attributes(url: "main/notify_prescription/#{notification.id}?" + "patient_id=" + params[:notification][:patient_id].to_s + "&notify_status=" + params[:notification][:notify_status].to_s)
        render json: {code: 1, message: t("notification.create.success")}
      else
        render json: {code: 2, message: t("notification.create.fails")}
      end
    end
  end

  def see
    @notification = Notification.unseen.where(user_id: @current_user.id, id: params[:id]).first
    @notification.seen! if @notification
    render json: {code: 1, data: t("common.success")}
  end

  private

  def notification_params
    params.require(:notification).permit :status
  end
end
