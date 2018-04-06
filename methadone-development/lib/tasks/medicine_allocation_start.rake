namespace :medicine_allocation_start do
  task init: :environment do
    MedicineAllocation.bulk_insert do |worker|
      today  = Date.today
      allocation_date = User.first.created_at
      start_day = allocation_date.to_date
      patient = Patient.all
      while start_day <= today
        prescriptions = Prescription.open.where("DATE(begin_date) <= ?", start_day)
                                         .where('DATE(end_date) >= ?', start_day)
        prescriptions.each do |prescription|
          nurse_id = User.where(issuing_agency_id: prescription.patient.issuing_agency_id).nurse.first.id
          if prescription.dosage_morning.nil? || prescription.dosage_morning == 0
            @medicine_allocation = MedicineAllocation.where("
              DATE(allocation_date) = ? and typee = 3 and patient_id = ?", start_day,
              prescription.patient_id)
            if @medicine_allocation.blank?
              worker.add allocation_date: allocation_date,
                dosage: prescription.dosage,
                status: 0, patient_id: prescription.patient_id,
                user_id: nurse_id, typee: 3
            end
          else
            @medicine_allocation_morning = MedicineAllocation.where("
              DATE(allocation_date) = ? and typee = 1 and patient_id = ?",start_day,
              prescription.patient_id)
            if @medicine_allocation_morning.blank?
              worker.add allocation_date: allocation_date, dosage: prescription.dosage_morning,
                status: 0, patient_id: prescription.patient_id,
                user_id: nurse_id, typee: 1
            end
            @medicine_allocation_afternoon = MedicineAllocation.where("
              DATE(allocation_date) = ? and typee = 2 and patient_id = ?", start_day,
              prescription.patient_id)
            if @medicine_allocation_afternoon.blank?
              worker.add allocation_date: allocation_date,
                dosage: prescription.dosage - prescription.dosage_morning,
                status: 0, patient_id: prescription.patient_id,
                user_id: nurse_id, typee: 2
            end
          end
        end
        start_day += 1.days
        allocation_date += 1.days
      end
    end
  end
end
