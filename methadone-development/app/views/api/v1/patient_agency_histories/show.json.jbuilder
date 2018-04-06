if @patient_agency_history.present?
  json.code 1
  json.message t("common.success")
  json.data do
    json.extract! @patient_agency_history, :id, :sender_id, :sender_agency_id, :receiver_agency_id, :status, :confirmer_id, :patient_id
    json.patient do
      json.merge! @patient_agency_history.patient.attributes
      json.birthdate @patient_agency_history.patient.birthdate.strftime "%d/%m/%Y" rescue nil
      json.admission_date @patient_agency_history.patient.admission_date.strftime "%d/%m/%Y" rescue nil
      json.issued_date @patient_agency_history.patient.issued_date.strftime "%d/%m/%Y" rescue nil
      if @patient_agency_history.patient.active == "deactived" && @patient_agency_history.patient.stop_treatment_histories.present?
        json.reason @patient_agency_history.patient.stop_treatment_histories.last.reason rescue nil
      end
      json.household_address @patient_agency_history.patient.address rescue nil
      json.household_hamlet @patient_agency_history.patient.hamlet rescue nil
      json.household_ward @patient_agency_history.patient.ward.name rescue nil
      json.household_district @patient_agency_history.patient.district.name rescue nil
      json.household_province @patient_agency_history.patient.province.name rescue nil
    end
    json.sender_name @patient_agency_history.sender.first_name + " " + @patient_agency_history.sender.last_name
    json.sender_agency_name @patient_agency_history.sender_agency.name
    json.receiver_agency_name @patient_agency_history.receiver_agency.name
    json.confirmer_name @patient_agency_history.confirmer.first_name + " " + @patient_agency_history.confirmer.last_name rescue nil
    json.date  @patient_agency_history.created_at.strftime "%d/%m/%Y" rescue nil
    json.end_date @patient_agency_history.end_date.strftime "%d/%m/%Y" rescue nil
  end
else
  json.code 2
  json.message "Yêu cầu chuyển cơ sở đã bị hủy"
end
