namespace :issuing_agency do
  task init: :environment do
    number = IssuingAgency.count
    issuing_agencies = []
    File.open("#{Rails.root}/lib/tasks/issuing_agency.csv").each_line do |line|
      issuing_agencies.push line.gsub("\n", "").split("|")
    end
    issuing_agencies.shift
    IssuingAgency.bulk_insert do |worker|
      issuing_agencies.each_with_index do |issuing_agency, index|
        tmp = number + index + 1
        province = Province.where(name: issuing_agency[2]).last
        district_name = '%' + issuing_agency[3] + '%'
        district = District.where("name like ?", district_name).where(province_id: province.id).last
        ward_name = '%' + issuing_agency[4] + '%'
        ward = Ward.where("name like ?", ward_name).where(district_id: district.id).last
        code = province.code + "0"*(2 - tmp.to_s.length) + tmp.to_s
        puts code
        worker.add name: issuing_agency[0], code: code,
                             province_id: province.id, district_id: district.id, ward_id: ward.id,
                             address: issuing_agency[1]
      end
    end
  end
end
