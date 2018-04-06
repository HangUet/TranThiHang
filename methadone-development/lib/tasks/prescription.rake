namespace :prescription do
  task init: :environment do
    patients = Patient.all
    # user = User.where("username = 'doctor'").first
    descriptions = ["Bệnh nhân có tiền sử bệnh tim, Bệnh nhân có tiền sử tiểu đường", "Bệnh nhân có tiền sử huyết áp cao"]
    Prescription.bulk_insert do |worker|
      patients.each_with_index do |patient, index|
        user = User.where(role: 2, issuing_agency_id: patient.issuing_agency_id).first
        if index % 2 == 0
          worker.add dosage: [*60..100].sample, begin_date: Time.now,
            dosage_morning: [*20..40].sample,
            medication_name: ["Methadose", "Methadol"].sample,
            end_date_expected: (Time.now + 10.days),
            end_date: (Time.now + 10.days),
            type_treatment: 2,
            patient_id: patient.id, user_id: user.id, close_status: 1,
            prescription_type: "H", description: descriptions.sample
        elsif index % 3 == 0
          worker.add dosage: [*1..20].sample, begin_date: Time.now - 1.month,
            medication_name: ["Methadose", "Methadol"].sample,
            end_date_expected: (Time.now),
            end_date: (Time.now),
            type_treatment: 2,
            patient_id: patient.id, user_id: user.id, close_status: 1,
            prescription_type: "N", description: descriptions.sample
        else
          worker.add dosage: [*1..20].sample, begin_date: Time.now - 1.month,
            medication_name: ["Methadose", "Methadol"].sample,
            end_date_expected: (Time.now - 1.days),
            end_date: (Time.now - 1.days),
            type_treatment: 2,
            patient_id: patient.id, user_id: user.id, close_status: 1,
            prescription_type: "N", description: descriptions.sample
        end
      end
    end
  end

  task update_medicine_list: :environment do
    patients = Patient.where("issuing_agency_id in (10, 14, 6, 15, 3, 16, 7, 11, 5)")
    patients.each do |p|
      p.prescriptions.update_all medicine_list_id: 2
    end

    patients = Patient.where("issuing_agency_id not in (10, 14, 6, 15, 3, 16, 7, 11)")
    patients.each do |p|
      p.prescriptions.update_all medicine_list_id: 1
    end
  end
end
