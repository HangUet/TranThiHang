json.code 1
json.message t("common.success")
json.data do
  json.id @vouchers.id
  json.typee @vouchers.typee
  json.datee @vouchers.datee.strftime "%d/%m/%Y" rescue nil
  json.number @vouchers.voucher_medicines.total rescue nil
  json.sender @vouchers.sender
  json.receiver @vouchers.receiver
  json.status @vouchers.status
  json.number_preventive @vouchers.voucher_medicines.total*5/100 rescue nil
end
