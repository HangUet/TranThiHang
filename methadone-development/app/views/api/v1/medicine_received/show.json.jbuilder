json.code 1
json.message t("common.success")
json.data do
  json.merge! @voucher_medicine.medicine.attributes
  json.expiration_date @voucher_medicine.medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.production_batch @voucher_medicine.medicine.production_batch
  json.remaining_number @voucher_medicine.number
  json.sender @voucher_medicine.voucher.sender
  json.receiver @voucher_medicine.voucher.receiver
end
