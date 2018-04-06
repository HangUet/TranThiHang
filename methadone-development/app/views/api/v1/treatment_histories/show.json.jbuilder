json.code 1
json.message t("common.success")
json.data do
  json.merge! @data
end
json.note @note
json.today do
  json.merge!(year: Time.now.strftime("%Y"),
    month: Time.now.strftime("%m"),
    day: Time.now.strftime("%d"),
    number_day: Time.days_in_month(Time.now.strftime("%m").to_i, Time.now.strftime("%Y").to_i))
end
