json.code 1
json.message t("common.success")
json.data @voucher_medicines do |voucher_medicine|
  json.id voucher_medicine.id
  json.name voucher_medicine.medicine.medicine_list.name rescue nil
  json.composition voucher_medicine.medicine.medicine_list.composition rescue nil
  json.concentration voucher_medicine.medicine.medicine_list.concentration rescue nil
  json.unit voucher_medicine.medicine.medicine_list.unit rescue nil
  json.price voucher_medicine.medicine.price rescue nil
  json.manufacturer voucher_medicine.medicine.medicine_list.manufacturer rescue nil
  json.provider voucher_medicine.medicine.provider.name rescue nil
  json.source voucher_medicine.medicine.source rescue nil
  json.expiration_date voucher_medicine.medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.production_batch voucher_medicine.medicine.production_batch rescue nil
  json.remaining_number voucher_medicine.medicine.remaining_number rescue nil
  json.sender voucher_medicine.voucher.sender rescue nil
  json.receiver voucher_medicine.voucher.receiver rescue nil
  json.booking voucher_medicine.medicine.booking rescue nil
  json.number voucher_medicine.number rescue nil
end
json.voucher_typee @voucher.typee
json.voucher_status @voucher.status
json.voucher_user_id @voucher.user_id
json.user_id @current_user.id
