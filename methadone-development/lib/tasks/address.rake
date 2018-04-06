namespace :address do
  task init: :environment do
    provinces = []
    districts = []
    wards = []
    File.open("#{Rails.root}/lib/tasks/provinces.csv").each_line do |line|
      provinces.push line.gsub("\n", "").split("|")
    end
    # File.open("/home/ax/methadone/lib/tasks/district.csv").each_line do |line|
    File.open("#{Rails.root}/lib/tasks/dictricts.csv").each_line do |line|
      districts.push line.gsub("\n", "").split("|")
    end
    File.open("#{Rails.root}/lib/tasks/wards.csv").each_line do |line|
      wards.push line.gsub("\n", "").split("|")
    end

    provinces.shift
    districts.shift
    wards.shift
    # provinces.each do |province|
    #   if province[2] == "Tỉnh"
    #     province[2] = "city"
    #   elsif province[2] == "Thành Phố"
    #     province[2] = "province"
    #   end
    # end
    # districts.each do |district|
    #   if district[2] == "Thị Xã"
    #     district[2] = "town"
    #   elsif district[2] == "Thành Phố"
    #     district[2] = "city"
    #   elsif district[2] == "Huyện"
    #     district[2] = "district"
    #   end
    # end
    # puts districts[0]

    provinces.each do |province|
      puts "---------------------"
      puts province[1]
      prv = Province.create name: province[1], code: province[0]
      districts.each do |district|
        if district[2] == province[0]
          puts district[1]
          dtr = District.create name: district[1], province_id: prv.id, code: district[0]
          Ward.bulk_insert(ignore: true) do |worker|
            wards.each do |ward|
              if ward[2] == district[0]
                worker.add({name: ward[1], district_id: dtr.id})
              end
            end
          end
        end
      end
    end
  end
end
