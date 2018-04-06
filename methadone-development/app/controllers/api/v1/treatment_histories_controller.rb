class Api::V1::TreatmentHistoriesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def show
    month_current = Time.now.strftime("%Y-%m")
    treatment_histories = TreatmentHistory.in_month(month_current, params[:id])
    @note = treatment_histories.present? ? treatment_histories.last.note : ""
    @data = TreatmentHistory.data_history(treatment_histories)
  end

  def update
    update_one_day
    render json: {code: 1, message: t("common.success")}
  end

  private

  def update_one_day
    current = Time.now.strftime("%Y-%m-%d")
    treatment_history = TreatmentHistory.in_month(current, params[:id])
    if treatment_history.present?
      treatment_history.first.update_attributes(treatment_params)
    else
      TreatmentHistory.create(treatment_params)
    end
  end

  def update_treatment
    data = params[:data]
    note = params[:note]
    month_current = Time.now.strftime("%Y-%m")
    data.each_with_index do |treatment, index|
      day = "#{month_current}-#{(index + 1).to_s.rjust(2,'0')}"
      treatment["treatment_date"] = day
      treatment["patient_id"] = params[:id]
      treatment["note"] = note
      treatment_history = TreatmentHistory.in_month(day, params[:id])
      if treatment_history.present?
        treatment_history.first.update_attributes(treatment_params(treatment))
      else
        TreatmentHistory.create(treatment_params(treatment))
      end
    end
  end

  def treatment_params
    params[:treatment_history][:note] = params[:note]
    params[:treatment_history][:patient_id] = params[:id]
    params[:treatment_history][:treatment_date] = Time.now
    params.require(:treatment_history).permit :treatment_date, :dosage, :syndrome, :drug_poisoning, :urine_test,
      :use_opium_substance, :other_opium_substance, :arv_treatment, :swap_syringe,
      :provide_condom, :counseling_support, :note, :patient_id
  end
end
