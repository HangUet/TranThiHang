json.code 1
json.data do
  json.merge! @prescription.attributes
  json.begin_date @prescription.begin_date.strftime "%d/%m/%Y" rescue nil
  json.end_date_expected @prescription.end_date_expected.strftime "%d/%m/%Y" rescue nil
  json.description @prescription.description rescue nil
  json.medicine_list_id @prescription.medicine_list
end
