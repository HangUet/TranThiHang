json.code 1
json.message t("common.success")
json.data @sub_vouchers do |voucher|
  json.id voucher.id
  json.typee voucher.typee
  json.datee voucher.datee.strftime "%d/%m/%Y" rescue nil
  json.sender voucher.sender
  json.receiver voucher.receiver
  json.status voucher.status
end
