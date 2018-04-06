namespace :patient_warnings do
  desc "Task create patient warnings"
  task create_warnings: :environment  do
    list_patient = Patient.pluck(:id)
    list_prescription_of_patient = Prescription.pluck(:patient_id)
    patient_not_have_prescription = list_patient - list_prescription_of_patient

    patient_not_have_prescription.each do |patient_id|
      tmp = PatientWarning.where(patient_id: patient_id).last
      if tmp.present?
        tmp.update_attributes(level: :obligatory,
          content: Settings.patient_warning.content.obligatory)
      else
        PatientWarning.create(level: :obligatory,
          content: Settings.patient_warning.content.obligatory,
          status: :open, patient_id: patient_id)
      end
    end
    today  = Date.today
    list_prescription = Prescription.open
                                     .where("DATE(begin_date) <= ?", today)
                                     .where('DATE(end_date) >= ?', today)
    list_prescription.each do |prescription|
      end_date = prescription.end_date.strftime "%d/%m/%Y"
      end_date_expected = Date.strptime(end_date, "%d/%m/%Y")
      current_time = today + 1.days
      if current_time == end_date_expected
        patient_warning = PatientWarning.where(patient_id: prescription.patient_id).last
        if patient_warning
          patient_warning.update_attributes(level: :optional,
            content: Settings.patient_warning.content.optional,
            status: :open)
        else
          PatientWarning.create(level: :optional,
            content: Settings.patient_warning.content.optional,
            status: :open, patient_id: prescription.patient_id)
        end
      elsif current_time > end_date_expected
        patient_warning = PatientWarning.where(patient_id: prescription.patient_id,
          level: :optional).last
        if patient_warning
          patient_warning.update_attributes(level: :obligatory,
            content: Settings.patient_warning.content.obligatory)
        end
      end
    end
  end
end
