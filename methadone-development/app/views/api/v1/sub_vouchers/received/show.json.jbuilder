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
      json.expiration_date sub_medicine.medicine.expiration_date.strftime "%d/%m/%Y"
      json.id sub_medicine.id
      json.sub_medicine_id sub_medicine.id
      json.name sub_medicine.medicine.medicine_list.name
      json.composition sub_medicine.medicine.medicine_list.composition
      json.unit sub_medicine.medicine.medicine_list.unit
      json.packing sub_medicine.medicine.medicine_list.packing
      json.medicine_list_id sub_medicine.medicine.medicine_list_id
      json.production_batch sub_medicine.medicine.production_batch
      json.concentration sub_medicine.medicine.medicine_list.concentration
      json.manufacturer sub_medicine.medicine.medicine_list.manufacturer
      json.provider sub_medicine.medicine.provider.name
      json.source sub_medicine.medicine.source rescue nil
      if @sub_voucher.typee == "import_end_day"
        day_medicine = DayMedicine.where(sub_medicine_id: sub_medicine.id,
                                         issuing_agency_id: @current_user.issuing_agency_id).first
        json.available_number day_medicine.remaining - day_medicine.booking + sub_voucher_sub_medicine.number
        json.remaining day_medicine.remaining
        json.booking day_medicine.booking
        json.day_medicine_id day_medicine.id
      else
        json.remaining sub_medicine.remaining - sub_medicine.booking
      end
      json.number_order sub_voucher_sub_medicine.number
      # json.status sub_medicine.status
    end
  end
end
