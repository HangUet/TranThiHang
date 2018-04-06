json.code 1
json.message t("common.success")
json.data @medicines do |medicine|
  json.id medicine.id
  json.name medicine.medicine_list.name rescue nil
  json.composition medicine.medicine_list.composition rescue nil
  json.concentration medicine.medicine_list.concentration rescue nil
  json.unit medicine.medicine_list.unit rescue nil
  json.packing medicine.medicine_list.packing rescue nil
  json.manufacturer medicine.medicine_list.manufacturer rescue nil
  json.provider medicine.provider.name rescue nil
  json.source medicine.source rescue nil
  json.expiration_date medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.production_batch medicine.production_batch rescue nil
  json.remaining_number medicine.remaining_number rescue nil
  json.booking medicine.booking rescue nil
  json.init_date medicine.init_date.strftime "%d/%m/%Y" rescue nil
  json.origin_medicine_id medicine.origin_medicine_id rescue nil
end
