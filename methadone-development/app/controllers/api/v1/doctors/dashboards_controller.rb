class Api::V1::Doctors::DashboardsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def index
    @dashboard = {total_patients: 0, total_expirate_prescription: 0, total_give_up_medicine: 0}
    today = Date.today
    total_patients = Patient.where(issuing_agency_id: @current_user.issuing_agency_id).size
    patient_have_prescrtiption = Patient.actived.joins(:prescriptions).where("DATE(end_date_expected) >= ? 
      and issuing_agency_id = ? and prescription_type != 'temp' and close_status = ?",
       today, @current_user.issuing_agency_id, Prescription.close_statuses[:open])
      .distinct.pluck(:id)
    total_expirate_prescription = (Patient.where(issuing_agency_id: @current_user.issuing_agency_id).pluck(:id) - patient_have_prescrtiption).length
    total_give_up_medicine = Patient.joins(:medicine_allocations)
      .where(issuing_agency_id: @current_user.issuing_agency_id)
      .where("medicine_allocations.status = ? and DATE(allocation_date) < ? and issuing_agency_id = ? and
        medicine_allocations.notify_status = ?",
        MedicineAllocation.statuses[:waiting], today, @current_user.issuing_agency_id,
        MedicineAllocation.notify_statuses[:not_fall])
      .distinct.count
    @dashboard[:total_patients] = total_patients
    @dashboard[:total_expirate_prescription] = total_expirate_prescription
    @dashboard[:total_give_up_medicine] = total_give_up_medicine

    render json: {data: @dashboard, message: t("common.success")}
  end
end
