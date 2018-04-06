namespace :medicine_list_prescription do
  task init: :environment do
    @prescriptions = Prescription.all
    @prescriptions.each do |prescription|
      if prescription.medication_name.present?
        MedicineList.all.each do |medicine_list|
          if prescription.medication_name.match(medicine_list.name)
            prescription.update medicine_list_id: medicine_list.id
          end
        end
      else
        prescription.medicine_list_id = MedicineList.first.id
      end
    end
  end
end
