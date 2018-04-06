json.code 1
json.message t("common.success")
json.data @patient_agency_histories do |patient_agency_history|
  json.sender_name patient_agency_history.sender.first_name + " " + patient_agency_history.sender.last_name
  json.sender_agency_name patient_agency_history.sender_agency.name rescue nil
  json.receiver_agency_name patient_agency_history.receiver_agency.name rescue nil
  json.confirmer_name patient_agency_history.confirmer.first_name + " " + patient_agency_history.confirmer.last_name rescue nil
  json.end_date patient_agency_history.end_date.strftime "%d/%m/%Y" rescue nil
  json.date_accepted patient_agency_history.date_accepted.strftime "%d/%m/%Y" rescue nil
end
