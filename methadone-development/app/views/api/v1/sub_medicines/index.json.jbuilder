json.code 1
json.message t("common.success")
json.data @sub_medicines do |sub_medicine|
  json.id sub_medicine.id
  json.name sub_medicine.medicine.medicine_list.name rescue nil
  json.composition sub_medicine.medicine.medicine_list.composition rescue nil
  json.concentration sub_medicine.medicine.medicine_list.concentration rescue nil
  json.unit sub_medicine.medicine.medicine_list.unit rescue nil
  json.packing sub_medicine.medicine.medicine_list.packing rescue nil
  json.manufacturer sub_medicine.medicine.medicine_list.manufacturer rescue nil
  json.provider sub_medicine.medicine.provider.name rescue nil
  json.source sub_medicine.medicine.source rescue nil
  json.expiration_date sub_medicine.medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.production_batch sub_medicine.medicine.production_batch rescue nil
  json.remaining sub_medicine.remaining rescue nil
  # if medicine.expiration_date.to_date >= @today && medicine.expiration_date <= (@today + 180.days)
  #   json.expirated_soon  1
  # end
end
# json.per_page Settings.per_page
# json.page params[:page].present? ? params[:page] : 1
# json.total @medicines.total_entries unless (params[:type] == "all" || params[:type] == "availability")
