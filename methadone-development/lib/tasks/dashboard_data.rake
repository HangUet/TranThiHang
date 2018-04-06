namespace :dashboard_data do
  task init: :environment do
    MedicineAllocation.bulk_insert do |worker|
      today  = Date.today
      allocation_date = Time.now - 5.days
      prescriptions = Prescription.open.where("DATE(begin_date) <= ?", today)
                                       .where('DATE(end_date) >= ?', today)
      prescriptions.each do |prescription|
        user = User.where(role: 3, issuing_agency_id: prescription.patient.issuing_agency_id).first
        if !prescription.dosage_morning.nil? && prescription.dosage_morning != 0
          worker.add allocation_date: allocation_date, dosage: prescription.dosage_morning,
            status: [0,1,2].sample, patient_id: prescription.patient_id,
            user_id: user.id, typee: 1

          worker.add allocation_date: allocation_date,
            dosage: prescription.dosage - prescription.dosage_morning,
            status: [0,1,2].sample, patient_id: prescription.patient_id,
            user_id: user.id, typee: 2
        else

          worker.add allocation_date: allocation_date,
            dosage: prescription.dosage,
            status: [0,1,2].sample, patient_id: prescription.patient_id,
            user_id: user.id, typee: 3
        end
      end
    end
  end
end
