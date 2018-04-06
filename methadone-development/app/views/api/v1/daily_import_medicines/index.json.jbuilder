json.code 1
json.message t("common.success")
json.data @medicines do |medicine|
  json.id medicine.id
  json.name medicine.name
  json.composition medicine.composition
  json.concentration medicine.concentration
  json.packing medicine.packing
  json.manufacturer medicine.manufacturer
  json.provider medicine.provider
  json.source medicine.source
  json.expiration_date medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.production_batch medicine.production_batch
  json.remaining_number medicine.remaining_number
  json.sender medicine.sender
  json.receiver medicine.receiver
end
