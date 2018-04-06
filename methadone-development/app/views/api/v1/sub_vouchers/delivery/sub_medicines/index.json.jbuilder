json.code 1
json.message t("common.success")
json.data @sub_medicines do |sub_medicine|
  json.expiration_date sub_medicine.medicine.expiration_date.strftime "%d/%m/%Y"
  json.id sub_medicine.id
  json.sub_medicine_id sub_medicine.id
  json.name sub_medicine.medicine.medicine_list.name
  json.composition sub_medicine.medicine.medicine_list.composition
  json.packing sub_medicine.medicine.medicine_list.packing
  json.medicine_list_id sub_medicine.medicine.medicine_list_id
  json.production_batch sub_medicine.medicine.production_batch
  json.concentration sub_medicine.medicine.medicine_list.concentration
  json.unit sub_medicine.medicine.medicine_list.unit
  json.manufacturer sub_medicine.medicine.medicine_list.manufacturer
  json.provider sub_medicine.medicine.provider.name
  json.source sub_medicine.medicine.source rescue nil
  json.avaialble_number sub_medicine.remaining - sub_medicine.booking
  json.remaining sub_medicine.remaining
  json.booking sub_medicine.booking
  json.init_date sub_medicine.init_date.strftime "%d/%m/%Y"
  json.flag "new"
end
