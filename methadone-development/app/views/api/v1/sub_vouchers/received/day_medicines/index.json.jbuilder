json.code 1
json.message t("common.success")
json.data @day_medicines do |day_medicine|
  json.expiration_date day_medicine.sub_medicine.medicine.expiration_date.strftime "%d/%m/%Y"
  json.day_medicine_id day_medicine.id
  json.sub_medicine_id day_medicine.sub_medicine.id
  json.name day_medicine.sub_medicine.medicine.medicine_list.name
  json.composition day_medicine.sub_medicine.medicine.medicine_list.composition
  json.unit day_medicine.sub_medicine.medicine.medicine_list.unit
  json.packing day_medicine.sub_medicine.medicine.medicine_list.packing
  json.medicine_list_id day_medicine.sub_medicine.medicine.medicine_list_id
  json.production_batch day_medicine.sub_medicine.medicine.production_batch
  json.concentration day_medicine.sub_medicine.medicine.medicine_list.concentration
  json.manufacturer day_medicine.sub_medicine.medicine.medicine_list.manufacturer
  json.provider day_medicine.sub_medicine.medicine.provider.name
  json.source day_medicine.sub_medicine.medicine.source rescue nil
  json.available_number day_medicine.remaining - day_medicine.booking
  json.remaining day_medicine.remaining
  json.booking day_medicine.booking
  json.init_date day_medicine.init_date rescue nil
  json.label "new"
end
