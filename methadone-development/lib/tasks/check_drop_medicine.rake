namespace :check_drop_medicine do
  task init: :environment do
    today = Date.today
    patients = Patient.all
    patient_drop_medicine_less_than_4_days = []
    patients.each do |patient|
      drop_medicine = DropMedicine.find_by_patient_id(patient.id)
      if drop_medicine.blank?
        drop_medicine = DropMedicine.create(patient_id: patient.id, total: 0)
      end
      if drop_medicine.total <= 4
        patient_drop_medicine_less_than_4_days << patient.id
      end
      if drop_medicine.total > 4
        if patient.prescriptions.open.present?
          drop_medicine.update_attributes(total: 0)
        else
          drop_medicine.update_attributes(total: drop_medicine.total + 1)
        end
        if drop_medicine.total >= 30
          prescription = patient.prescriptions.last
          issuing_agency = IssuingAgency.find_by_id(patient.issuing_agency_id)
          executive_staffs = issuing_agency.users.executive_staff
          admin_agencies = issuing_agency.users.admin_agency
          executive_staffs.each do |executive_staff|
            notification = Notification.new user_id: executive_staff.id, content: 'Bệnh nhân bỏ uống thuốc 30 ngày'
            notification.update_attributes(url: "main/renunciated/#{notification.id}?patient_id=" + patient.id.to_s + "&dosage=" + prescription.dosage.to_s + "&prescription=" + prescription.id.to_s)
          end
          
          admin_agencies.each do |admin_agency|
            notification = Notification.new user_id: admin_agency.id, content: 'Bệnh nhân bỏ uống thuốc 30 ngày'
            notification.update_attributes(url: "main/renunciated/#{notification.id}?patient_id=" + patient.id.to_s + "&dosage=" + prescription.dosage.to_s + "&prescription=" + prescription.id.to_s)
          end
        end
      end
    end
    #check benh nhan bo uong it hon 4 ngay
    prescriptions = Prescription.open.where("DATE(begin_date) <= ?", today)
                                     .where('DATE(end_date) >= ?', today)
                                     .where(patient_id: patient_drop_medicine_less_than_4_days)
    prescriptions.each do |prescription|
      @medicine_allocation = MedicineAllocation.where("DATE(allocation_date) = ? and patient_id = ?", today, prescription.patient_id).last
      drop_medicine = DropMedicine.find_by_patient_id(prescription.patient_id)

      if @medicine_allocation.blank? || @medicine_allocation.status == "waiting"
        drop_medicine.update_attributes(total: drop_medicine.total + 1)
      else
        drop_medicine.update_attributes(total: 0)
      end

      if drop_medicine.total >= 4
        prescriptions = Patient.find_by_id(prescription.patient_id).prescriptions.update_all(close_status: 2)
      end
    end
  end
end
