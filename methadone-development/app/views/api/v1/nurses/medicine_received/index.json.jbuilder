json.code 1
json.message t("common.success")
json.data @voucher_medicines do |voucher_medicine|
  json.id voucher_medicine.id
  json.name voucher_medicine.medicine.medicine_list.name
  json.composition voucher_medicine.medicine.medicine_list.composition
  json.concentration voucher_medicine.medicine.medicine_list.concentration
  json.packing voucher_medicine.medicine.medicine_list.packing
  json.manufacturer voucher_medicine.medicine.medicine_list.manufacturer
  json.provider voucher_medicine.medicine.provider.name
  json.source voucher_medicine.medicine.source rescue nil
  json.expiration_date voucher_medicine.medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.production_batch voucher_medicine.medicine.production_batch
  json.remaining_number voucher_medicine.number
  json.sender voucher_medicine.voucher.sender
  json.receiver voucher_medicine.voucher.receiver
end
