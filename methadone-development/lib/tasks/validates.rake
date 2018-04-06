namespace :validates do
  task test: :environment do
    puts "-------- test create patient ---------"
    mobile_phones = ["01234567", "012345678", "0123456789", "01234567890",
      "012345678901", "123456789", "10234567891"]

    saves = []
    test_results = [false, false, true, true, true, false, false]
    ward = Ward.first
    mobile_phones.each do |mobile_phone|
      patient = Patient.find_by(card_number: mobile_phone + "123123")
      patient.destroy if patient.present?
      p =  Patient.new(
        card_number: mobile_phone + "123123",
        name: "test",
        birthdate: Date.today,
        gender: "male",
        mobile_phone: mobile_phone,
        identification_number: "12313123",
        identification_issued_date: Date.today,
        identification_issued_by: "test",
        admission_date: Date.today,
        referral_agency: "test",
        district_id: ward.district_id,
        province_id: ward.district.province_id,
        issuing_agency_id: IssuingAgency.first.id
      )
      saves << p.save
    end
    puts "#{saves}"
    puts "Test results: #{saves == test_results}"


    puts "\n-------- test create patient contact --------"
    saves = []
    p = PatientContact.create(contact_type: 0, patient_id: Patient.first.id)
    saves << p.save
    p = PatientContact.create(name: "test", patient_id: Patient.first.id)
    saves << p.save
    p = PatientContact.create(contact_type: 0, name: "test", patient_id: Patient.first.id)
    saves << p.save
    puts "#{saves}"
    puts "Test results: #{saves == [false, false, true]}"


    puts "\n------- test vouchers ------"
    saves = []
    p = Voucher.new(typee: 0, issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    p = Voucher.new(sender: "test", issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    p = Voucher.new(receiver: "test", issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    p = Voucher.new(typee: 0, sender: "test", receiver: "test")
    saves << p.save
    p = Voucher.new(typee: 0, sender: "test", receiver: "test",
      issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    puts "#{saves}"
    puts "Test result: #{saves == [false, false, false, false, true]}"


    puts "\n------- test issuing_agencies ------"
    saves = []
    p = IssuingAgency.new(name: "test")
    saves << p.save
    p = IssuingAgency.new(name: "t"*81)
    saves << p.save
    p = IssuingAgency.new(code: "test")
    saves << p.save
    p = IssuingAgency.new(address: "test")
    saves << p.save
    p = IssuingAgency.new(name: "test", code: "test", address: "test")
    saves << p.save
    p = IssuingAgency.new(name: "test", code: "test", address: "test",
      ward_id: ward.id, district_id: ward.district_id, province_id: ward.district.province_id)
    saves << p.save
    puts "#{saves}"
    puts "Test result: #{saves == [false, false, false, false, false, true]}"


    puts "\n------- test issuing_agencies ------"
    saves = []
    p = Medicine.new(name: "a"*256, issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    p = Medicine.new(manufacturer: "a"*256, issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    p = Medicine.new(remaining_number: -1, issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    p = Medicine.new(name: "test", composition: "test", concentration: 4,
      packing: "test", manufacturer: "test", provider: "test", source: "test",
      production_batch: "test", expiration_date: Date.today, remaining_number: 3,
      issuing_agency_id: IssuingAgency.first.id)
    saves << p.save
    puts "#{saves}"
    puts "Test result: #{saves == [false, false, false, true]}"


    puts "\n------- test prescriptions ------"
    saves = []
    p = Prescription.new(dosage: 0, user_id: User.first.id, patient_id: Patient.first.id)
    saves << p.save
    p = Prescription.new(dosage: 1, user_id: User.first.id, patient_id: Patient.first.id,
      prescription_type: 1, begin_date: Date.today, end_date_expected: Date.today)
    saves << p.save
    puts "#{saves}"
    puts "Test result: #{saves == [false, true]}"


    puts "\n------- test voucher_medicines ------"
    saves = []
    p = VoucherMedicine.new(number: 3, medicine_id: Medicine.first.id)
    saves << p.save
    p = VoucherMedicine.new(number: 4, medicine_id: Medicine.first.id,
      voucher_id: Voucher.first.id)
    saves << p.save
    puts "#{saves}"
    puts "Test result: #{saves == [false, true]}"
  end
end
