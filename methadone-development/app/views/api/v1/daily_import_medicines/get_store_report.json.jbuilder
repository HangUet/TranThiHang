json.code 1
json.message t("common.success")
json.data do
  json.reports  @reports
  json.total_patients @total_patients
end
