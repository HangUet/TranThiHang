json.code 1
json.message t("common.success")
json.data @medicines do |medicine|
  json.merge! medicine.attributes
  json.expiration_date medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
end
