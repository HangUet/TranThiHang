json.code 1
json.message t("common.success")
json.data @patients do |patient|
  json.merge! patient.attributes
  tmp = patient.patient_agency_histories.last.status rescue nil
  status = "allow"
  if tmp.present? && tmp == "pending"
    status = "not_allowed"
  end
  json.status status
end
json.per_page Settings.per_page
json.page params[:page]
json.total @patients.total_entries
