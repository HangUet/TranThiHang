namespace :check_drop_medicine_4_days do
  task init: :environment do
    patients = Patient.all.pluck(:id)
    today = Date.today
    patients.each do |patient|
    start_treatment_before_4_days = Prescription.where(patient_id: patient)
       .where("DATE(begin_date) <= ?", today - 4.days)
      if start_treatment_before_4_days.present?
        stop_treatment = 1
        1.upto(4) do |i|
          check = MedicineAllocation.where("status != 0 and DATE(allocation_date) = ? and patient_id = ? and notify_status = ?",
            today - i.days, patient, MedicineAllocation.notify_statuses[:not_fall])
          if check.present?
            stop_treatment = 0
            return
          end
        end
      else
       stop_treatment = 0
      end
      if stop_treatment == 1
        prescriptions = Patient.find_by_id(patient).prescriptions.update_all(close_status: 2)
      end
    end
  end
end
