namespace :import_patient do
  desc "Task description"
  task init: :environment do

    # sheets
    #  0: STT
    #  1: ma co so
    #  2: ho ten
    #  3: nam sinh
    #  4: gioi tinh
    #  5: nghe nghiep
    #  6: dan toc
    #  7: tinh trang hon nhan
    #  8: trinh do hoc van
    #  9: CMND
    #  10: ngay cap
    #  11: Noi cap
    #  12: Tinh hinh tai chinh
    #  13: Ngay vao dieu tri
    #  14: Dia chi
    #  15: Thanh pho
    #  16: Quan/Huyen
    #  17: Phuong
    #  18: To/Thon
    #  19: ho ten nguoi lien he 1
    #  20: dia chi nguoi lien he 2
    #  21: SDT nguoi lien he 1
    #  22: Moi quan he
    #  23: Tinh trang dieu tri

    require 'roo'

    workbook = Roo::Spreadsheet.open("#{Rails.root}/lib/tasks/patient-1.xlsx")
    empty_list = File.open("#{Rails.root}/lib/tasks/empty_ward.txt", "w")
    patients = workbook.sheet('T1')

    patients.each_with_index do|patient, index|
      if index > 7 && !patient[0].nil?
        name = patient[2]
        if name.present?
          birthday = patient[3] rescue nil
          gender = patient[4].squish == "Nam" ? "male" : "female" rescue nil
          jobs = patient[5].squish rescue nil
          ethnicity_id = Ethnicity.find_by(name: patient[6].squish).id rescue nil
          ward_name = "%" + patient[17].squish + "%" rescue nil
          ward = Ward.where("name like ?", ward_name).first rescue nil
          ward_id = ward.id rescue nil
          district_id = ward.district_id rescue nil
          province_id = ward.district.province_id rescue nil
          hamlet = patient[18].squish rescue nil
          address = patient[14].squish rescue nil
          mobile_phone = nil

          marital_status = nil
          if patient[7].present?
            case patient[7].squish
            when "Độc thân"
              marital_status = "single"
            when "Đã kết hôn"
              marital_status = "married"
            when "Ly thân"
              marital_status = "separated"
            when "Ly dị"
              marital_status = "divorced"
            when "Chồng/Vợ đã mất"
              marital_status = "widowed"
            else
              marital_status = nil
            end
          end

          education_level = nil
          if patient[8].present?
            case patient[8].squish
            when "Cấp 1/Tiều học"
              education_level = "Primary"
            when "Cấp 2/ Trung học cơ sở"
              education_level = "Middle"
            when "Cấp 3/Trung học phổ thông"
              education_level = "High"
            when "Học nghề/Trung học/Cao đẳng/Đại học/…"
              education_level = "Tertiary"
            when "Khác"
              education_level = "Difference"
            else
              education_level = nil
            end
          end

          financial_status = nil
          if patient[12].present?
            temp = patient[12].squish
            if temp.include? "VND/tháng"
              temp = temp.split("VND/tháng")
            else
            end

            case patient[12].squish
            when "Thu nhập hàng tháng"
              financial_status = "Monthly Income"
            when "Thu nhập hàng ngày"
              financial_status = "Daily Income"
            when "Khác"
              financial_status = "Difference"
            else
              financial_status = nil
            end
          end

          admission_date = patient[13].squish rescue nil
          referral_agency = nil
          issued_date = nil
          identification_number = patient[9].squish rescue nil
          identification_issued_date = patient[10]
          identification_issued_by = patient[11]
          health_insurance_code = nil
          patient_stt = Patient.where(issuing_agency_id: 1)
          issuing_agency = IssuingAgency.find(1)
          if patient_stt.length > 0
            tmp = patient_stt.count + 1
            stt = "0"*(5 - tmp.to_s.length) + tmp.to_s
          else
            stt = "00001"
          end
          id_card_number =  ward.district.code.to_s + issuing_agency.code.to_s + stt rescue nil
          puts id_card_number
          info = patient[17].to_s + "  " + patient[16].to_s + "  " + patient[15].to_s
          if id_card_number.blank?
            empty_list.puts info
          end
          patient_new = Patient.new(name: name, gender: gender, birthdate: birthday,
            jobs: jobs, ethnicity_id: ethnicity_id, province_id: province_id,
            district_id: district_id, ward_id: ward_id, hamlet: hamlet,
            address: address, mobile_phone: mobile_phone, marital_status: marital_status,
            education_level: education_level, financial_status: financial_status,
            admission_date: admission_date, referral_agency: referral_agency,
            card_number: id_card_number, issued_date: issued_date,
            issuing_agency_id: 1, identification_number: identification_number,
            identification_issued_date: identification_issued_date,
            identification_issued_by: identification_issued_by,
            health_insurance_code: health_insurance_code)
          patient_new.save
        end
      end
    end
  end
end
