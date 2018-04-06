json.code 1
json.message t("common.success")
json.data do
  json.id @sub_voucher.id
  json.typee @sub_voucher.typee
  json.datee @sub_voucher.datee.strftime "%d/%m/%Y" rescue nil
  json.sender @sub_voucher.sender
  json.receiver @sub_voucher.receiver
  json.status @sub_voucher.status
  if @sub_medicines.length > 0
    json.sub_medicines @sub_medicines.each do |sub_medicine|
      sub_voucher_sub_medicine = SubVoucherSubMedicine.where(sub_voucher_id: @sub_voucher.id, sub_medicine_id: sub_medicine.id).first
      # json.expiration_date sub_medicine.expiration_date.strftime "%d/%m/%Y"
      json.id sub_medicine.id
      json.sub_medicine_id sub_medicine.id
      # json.name sub_medicine.medicine_list.name
      # json.composition sub_medicine.medicine_list.composition
      # json.packing sub_medicine.medicine_list.packing
      # json.medicine_list_id sub_medicine.medicine_list_id
      # json.production_batch sub_medicine.production_batch
      # json.concentration sub_medicine.medicine_list.concentration
      # json.manufacturer sub_medicine.medicine_list.manufacturer
      # json.provider sub_medicine.medicine_list.provider
      # json.source sub_medicine.source rescue nil
      json.remaining sub_medicine.remaining
      json.booking sub_medicine.booking
      json.number_order sub_voucher_sub_medicine.number
      # json.status sub_medicine.status
    end
  end
end
