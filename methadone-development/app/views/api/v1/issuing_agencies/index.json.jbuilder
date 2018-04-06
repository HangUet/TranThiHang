json.code 1
json.message t("common.success")
json.data @issuing_agencies do |issuing_agency|
  json.id issuing_agency.id
  json.name issuing_agency.name
  json.code issuing_agency.code
  json.address issuing_agency.address
  json.province issuing_agency.province.name
  json.district issuing_agency.district.name
  json.ward issuing_agency.ward.name
  json.count issuing_agency.patients.count
end
json.page do
  json.merge!(per_page: Settings.per_page, page: params[:page],
    total: @issuing_agencies.total_entries)
end
