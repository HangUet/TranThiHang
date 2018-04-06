json.code 1
json.message t("common.success")
json.data @medicines  do |medicine|
  json.merge! medicine.attributes
  json.medicine_type medicine.medicine_type.name rescue nil
  json.status medicine.status
end
json.per_page Settings.per_page
json.page params[:page]
json.total @medicines.total_entries
