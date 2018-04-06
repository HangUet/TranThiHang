namespace :patient do

  task set_card_number: :environment do
    IssuingAgency.all.each do |ia|
      temp = 0;
      puts "--------------------------"
      ia.patients.each do |patient|
        temp = temp + 1
        code = patient.card_number[0..4].to_s + temp.to_s.rjust(5, "0")
        puts code
        puts "++++++++++++++++++++++"
        puts patient.card_number
        patient.update_attributes card_number: code
      end
    end
  end

  task f_son_tay: :environment do
    temp = 0
    Patient.where(issuing_agency_id: 3).order(:admission_date).each do |patient|
      puts patient.admission_date
      puts patient.card_number
      temp = temp + 1
      code = patient.card_number[0..4].to_s + temp.to_s.rjust(5, "0") + temp.to_s.rjust(5, "0")
      patient.update_attributes card_number: code
      puts patient.admission_date
      puts patient.card_number
      puts "---------------"
    end
    Patient.where(issuing_agency_id: 3).order(:admission_date).each do |patient|
      patient.update_attributes card_number: patient.card_number[0..-6]
    end

  end

  task init: :environment do
    # Patient.create
    list_id = IssuingAgency.all.pluck(:id)
    list_id.each do |issuing_agency_id|
      50.times.each do |i|
        province_id = [*1..63].sample
        district = District.where(province_id: province_id).order(Arel::Nodes::NamedFunction.new('RAND', [])).limit(1).first
        district_id = district.id
        ward_id_temp = Ward.where(district_id: district_id).order(Arel::Nodes::NamedFunction.new('RAND', [])).limit(1).first
        if !ward_id_temp.nil?
           ward_id = ward_id_temp.id
        else
           ward_id = Settings.randoms_ward
        end
        first_name = Faker::Name.first_name
        middle_name = Faker::Name.last_name
        last_name = Faker::Name.last_name
        issued_date = Faker::Date.backward(3650)
        # issuing_agency_id = [*1..20].sample
        issuing_agency_name = IssuingAgency.find(issuing_agency_id).name
        id_str = (i + 1).to_s.rjust(5, '0')
        issuing_agency = IssuingAgency.find(issuing_agency_id)
        patient_stt = Patient.where(issuing_agency_id: issuing_agency_id)
        if patient_stt.length > 0
          tmp = patient_stt.count + 1
          stt = "0"*(5 - tmp.to_s.length) + tmp.to_s
        else
          stt = "00001"
        end
        id_card_number = issuing_agency.code.to_s + stt
        puts id_card_number
        identification_issued_by = Province.find(province_id).name
        identification_number = Faker::Number.number(8)
        Patient.create name: "#{first_name} #{middle_name} #{last_name}",
                       admission_date: Faker::Date.backward(3650),
                       referral_agency: Faker::Company.name,
                       card_number: id_card_number,
                       issued_date: issued_date,
                       issuing_agency_id: issuing_agency_id,
                       birthdate: Faker::Date.backward(9650),
                       gender: ["male", "female"].sample,
                       ethnicity_id: [*1..54].sample,
                       marital_status: ["single", "married", "separated", "divorced", "widowed"].sample,
                       no_of_children: [*1..8].sample,
                       address: "#{[*1..100].sample} #{Faker::Name.name}" ,
                       district_id: district_id,
                       province_id: province_id,
                       hamlet: Faker::Address.city,
                       ward_id: ward_id,
                       mobile_phone: "0" + Faker::Number.number(10),
                       jobs: Faker::Job.field,
                       financial_status: ["Monthly Income", "Daily Income"].sample,
                       education_level: ["Primary", "Middle", "Tertiary"].sample,
                       identification_type: rand(4),
                       identification_number: identification_number,
                       identification_issued_date: issued_date,
                       identification_issued_by: identification_issued_by,
                       health_insurance_code: Faker::Number.number(10)
      end
    end
  end
end
