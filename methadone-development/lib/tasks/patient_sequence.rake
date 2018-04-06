namespace :patient_sequences do
  task init: :environment  do
    IssuingAgency.all.each do |issuing_agency|
      last_patient = Patient.where("card_number like '#{issuing_agency.code}%'" ).order(:card_number).last

      PatientSequence.create issuing_agency_id: issuing_agency.id, number: last_patient.card_number.to_s.last(5)
    end
  end
end
