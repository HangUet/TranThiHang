namespace :medicine_list do
  task init: :environment do
    MedicineList.bulk_insert do |worker|
      worker.add name: "Methadose", composition: "Methadone hydroclorid",
        concentration: 10, packing: 1000, manufacturer: "Vistapharm Inc",
        medicine_type_id: 1
      worker.add name: "Methadose", composition: "Methadone hydroclorid",
        concentration: 10, packing: 1000, manufacturer: "Hataphar",
        medicine_type_id: 1
      worker.add name: "Methadol", composition: "Methadone hydroclorid",
        concentration: 10, packing: 1000, manufacturer: "Vistapharm Inc",
        medicine_type_id: 1
      worker.add name: "Methadol", composition: "Methadone hydroclorid",
        concentration: 10, packing: 1000, manufacturer: "Mekophar",
        medicine_type_id: 1
      worker.add name: "Methadol", composition: "Methadone hydroclorid",
        concentration: 10, packing: 1000, manufacturer: "Vidipha",
        medicine_type_id: 1
    end
  end
end
