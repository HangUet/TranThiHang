json.code 1
json.message t("common.success")
json.data do
  json.merge! @patient.attributes
  json.merge!(ethnicity_name: @patient.ethnicity_name,
    district_name: @patient.district_name,
    province_name: @patient.province_name)
  json.birthdate @patient.birthdate.strftime "%d/%m/%Y" rescue nil
  json.admission_date @patient.admission_date.strftime "%d/%m/%Y" rescue nil
  json.issued_date @patient.issued_date.strftime "%d/%m/%Y" rescue nil
  json.identification_type @patient.identification_type
  json.identification_issued_date @patient.identification_issued_date.strftime "%d/%m/%Y" rescue nil
  json.notifi  @notifi rescue nil
  json.dosage  @prescription.dosage rescue "Chưa điều trị"
  json.description  @prescription.description rescue "Chưa điều trị"
  json.contacts @patient.patient_contacts do |contact|
    json.extract! contact, :id, :name, :address, :contact_type, :telephone
  end
  if @patient.active == "deactived" && @patient.stop_treatment_histories.present?
    json.reason @patient.stop_treatment_histories.last.reason rescue nil
  end
  json.actived @patient.active rescue nil
  json.pending_change_agency @patient.patient_agency_histories.pending.last
  json.receiver_agency @patient.patient_agency_histories.pending.last.receiver_agency.name rescue nil
  json.resident_address @patient.resident_address rescue nil
  json.resident_hamlet @patient.resident_hamlet rescue nil
  json.resident_ward @patient.resident_ward.name rescue nil
  json.resident_district @patient.resident_district.name rescue nil
  json.resident_province @patient.resident_province.name rescue nil
  json.household_address @patient.address rescue nil
  json.household_hamlet @patient.hamlet rescue nil
  json.household_ward @patient.ward.name rescue nil
  json.household_district @patient.district.name rescue nil
  json.household_province @patient.province.name rescue nil

  status = "allow"
  if @current_user.role != "admin_agency"
    tmp = @patient.prescriptions rescue nil

    if tmp.present?
      status = "not_allowed"
    end
  end
  json.status status
  json.check_agency @patient.issuing_agency_id == @current_user.issuing_agency_id ? 1 : 0
end
