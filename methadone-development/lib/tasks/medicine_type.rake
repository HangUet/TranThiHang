namespace :medicine_type do
  desc "Rake medicine type"
  task init: :environment do
    medicine_types = ["Methadone hydroclorid", "Buprenorphine", "Buprenorphine / Naloxone"]
    medicine_types.each do |medicine_type|
      MedicineType.create(name: medicine_type)
    end

  end
end
