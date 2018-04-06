json.code 1
json.message t("common.success")
i = 0
json.data @medicine_list.each_with_index do |medicine|
  json.composition        medicine.composition rescue nil
  json.concentration      medicine.concentration rescue nil
  json.packing            medicine.packing rescue nil
  json.production_batch   @medicines[i].production_batch rescue nil
  json.expiration_date    @medicines[i].expiration_date.strftime("%d/%m/%Y") rescue nil
  json.manufacturer       medicine.manufacturer rescue nil
  json.provider           medicine.provider rescue nil
  json.source             medicine.source rescue nil
  json.number             @sub_medicine_sub_voucher[i] rescue nil
  i = i + 1
end
