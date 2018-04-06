namespace :patient_contacts do
  task init: :environment do
    patients = Patient.all
    PatientContact.bulk_insert do |worker|
      patients.each do |patient|
        worker.add name: Faker::Name.name,
                              address: "#{[*1..100].sample} #{Faker::Name.name}",
                              contact_type: 0,
                              telephone: "0" + Faker::Number.number(10),
                              patient_id: patient.id
        worker.add name: Faker::Name.name,
                              address: "#{[*1..100].sample} #{Faker::Name.name}",
                              contact_type: 1,
                              telephone: "0" + Faker::Number.number(10),
                              patient_id: patient.id
        worker.add name: Faker::Name.name,
                              address: "#{[*1..100].sample} #{Faker::Name.name}",
                              contact_type: 2,
                              telephone: "0" + Faker::Number.number(10),
                              patient_id: patient.id
        worker.add name: Faker::Name.name,
                              address: "#{[*1..100].sample} #{Faker::Name.name}",
                              contact_type: 3,
                              telephone: "0" + Faker::Number.number(10),
                              patient_id: patient.id
      end
    end
  end
end
