namespace :newcategory do
  task init: :environment do
    StopReason.bulk_insert do |worker|
      ['Bị bắt vào trai cai nghiện', 'Tự ý bỏ điều trị', 'Tự nguyện ra khỏi chương trình', 'Bị bắt tù', 'Đã chết', 'Lý do khác'].each do |reason|
        worker.add name: reason, status: 1
      end
    end

    Provider.bulk_insert do |worker|
      ['CPC1', 'Liên danh Hataphar-CPC1', 'Codupha', 'Vidipha- Sapharco'].each do |provider|
        worker.add name: provider, status: 1
      end
    end

    Manufacturer.bulk_insert do |worker|
      ['Vistapharm Inc', 'Mallinckordt Inc', 'Hataphar', 'Mekophar', 'Vidipha', 'Danapha'].each do |manufacturer|
        worker.add name: manufacturer, status: 1
      end
    end
    MedicineList.bulk_insert do |worker|
      worker.add name: "Buprenorphine", composition: "Buprenorphine",
        concentration: 20, medicine_type_id: 2
      worker.add name: "Buprenorphine", composition: "Buprenorphine",
        concentration: 80, medicine_type_id: 2
      worker.add name: "Suboxome", composition: "Buprenorphine / Naloxone", medicine_type_id: 2
    end
  end
end
