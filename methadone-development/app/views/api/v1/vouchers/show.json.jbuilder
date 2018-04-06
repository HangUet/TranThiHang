json.code 1
json.message t("common.success")
json.data do
  json.id @voucher.id
  json.typee @voucher.typee
  json.datee @voucher.datee.strftime "%d/%m/%Y" rescue nil
  json.sender @voucher.sender
  json.receiver @voucher.receiver
  json.identification_card_sender @voucher.identification_card_sender
  json.agency_sender_receiver @voucher.agency_sender_receiver
  json.status @voucher.status
  json.code @voucher.code
  json.invoice_number @voucher.invoice_number
  json.total_money @voucher.total_money
  json.identification_card_sender @voucher.identification_card_sender rescue nil
  if @medicines.present?
    json.provider_id @medicines[0].provider_id
    json.provider @medicines[0].provider.name rescue nil
    json.source @medicines[0].source
    json.medicines @medicines.each do |medicine|
      voucher_medicine = VoucherMedicine.where(voucher_id: @voucher.id, medicine_id: medicine.id).first
      json.expiration_date medicine.expiration_date.strftime "%d/%m/%Y"
      json.id medicine.id
      json.medicine_id medicine.id
      json.name medicine.medicine_list.name
      json.composition medicine.medicine_list.composition
      json.packing medicine.medicine_list.packing
      json.medicine_list_id medicine.medicine_list_id
      json.production_batch medicine.production_batch
      json.concentration medicine.medicine_list.concentration
      json.unit medicine.medicine_list.unit
      json.manufacturer medicine.medicine_list.manufacturer
      json.provider medicine.provider.name
      json.source medicine.source
      json.available_number medicine.remaining_number - medicine.booking
      json.remaining_number medicine.remaining_number
      json.booking medicine.booking
      json.number_order voucher_medicine.number
      json.status medicine.status
      json.price medicine.price.round(2)
      json.init_date medicine.init_date.strftime "%d/%m/%Y" rescue nil
    end
  end
end
