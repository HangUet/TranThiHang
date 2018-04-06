json.code 1
json.message t("common.success")
if (params[:patient_id] && params[:from_date] && params[:to_date])
  json.data @history_medicine_allocation do |history|
    json.dosage history.dosage
    json.day_hour history.updated_at.strftime "%d/%m/%Y %H:%M:%S" rescue nil
    json.medical_instruction history.prescription.description rescue nil
  end
else
  json.dosage_morning        @prescription.dosage_morning rescue nil
  json.dosage                @prescription.dosage rescue nil
  json.patient_warning       @warning ? @warning : nil
  json.allow_allocation      @allow_allocation == 1
  json.waiting_doctor        @waiting_doctor ? @waiting_doctor : nil
  json.description           @prescription.description rescue nil
  json.medicine              @prescription.medicine_list.name rescue nil
  json.day_medicines @day_medicines do |day_medicine|
    json.id day_medicine.id
    json.production_batch day_medicine.production_batch
    json.name day_medicine.medicine_list.name
    json.expiration_date day_medicine.expiration_date.strftime "%d/%m/%Y" rescue nil
    json.manufacturer day_medicine.medicine_list.manufacturer
    json.remaining_number day_medicine.remaining_number
    json.booking day_medicine.booking
    json.concentration day_medicine.medicine_list.concentration
  end

  json.data @medical_allocations do |medical_allocation|
    json.id  medical_allocation ? medical_allocation.id                                            : nil
    json.allocation_date       medical_allocation ? Date.today.day                                 : nil
    json.patient_id            medical_allocation ? medical_allocation.patient_id                  : nil
    json.allocator_id          medical_allocation ? medical_allocation.user_id                     : nil
    json.dosage                medical_allocation ? medical_allocation.dosage                      : nil
    json.status                medical_allocation ? medical_allocation.status                      : nil
    json.status_integer        medical_allocation ? medical_allocation.read_attribute(:status)     : nil
    json.notify_status         medical_allocation ? medical_allocation.notify_status               : nil
    json.typee                 medical_allocation ? medical_allocation.typee                       : nil
  end
end
