json.code 1
json.message t("common.success")
json.data @received_sub_vouchers do |delivery_sub_voucher|
  json.id                        delivery_sub_voucher.id
  json.agency_receiver           delivery_sub_voucher.agency_receiver rescue nil
  json.created_at                delivery_sub_voucher.created_at.strftime "%d/%m/%Y" rescue nil
  json.datee                     delivery_sub_voucher.datee.strftime "%d/%m/%Y" rescue nil
  json.issuing_agency_id         delivery_sub_voucher.issuing_agency_id rescue nil
  json.receiver                  delivery_sub_voucher.receiver rescue nil
  json.sender                    delivery_sub_voucher.sender rescue nil
  json.status                    delivery_sub_voucher.status rescue nil
  json.typee                     delivery_sub_voucher.typee rescue nil
end
# json.page do
#   json.merge!(per_page: Settings.per_page, page: params[:page],
#     total: @issuing_agencies.total_entries)
# end
json.data received_sub_vouchers do |received_sub_voucher|
  json.id received_sub_voucher.id
  json.typee received_sub_voucher.typee
  json.datee received_sub_voucher.datee.strftime "%d/%m/%Y" rescue nil
  json.sender received_sub_voucher.sender
  json.receiver received_sub_voucher.receiver
  json.status received_sub_voucher.status
end
