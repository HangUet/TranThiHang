namespace :import_patient_tay_ho do
  desc "Task description"
  task init: :environment do
    def get_gender gender
      gender = gender.squish
      if gender == "Nam" || gender == "nam" || gender == "NAM"
        gender = "male"
      elsif gender == "Nữ" || gender == "nữ" || gender == "NỮ"
        gender = "female"
      else
        gender = "other"
      end
      return gender
    end
#["CSDTMMTTrungtamchuabenhgiaoduclaodongxahoiso5.xlsx", "CSĐT MMT Trung tâm chữa bệnh, giáo dục, lao động xã hội số 5"],
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
    agency_list = [["CSDTMMTTTayHo.xlsx", "CSĐT MMT Tây Hồ"]]
    patient_stt = Patient.count.to_i
    identity_card_number_fake = Patient.where("identification_number like '00000000%'").count.to_i
    agency_list.each do |agency|
      patients_list = []
      workbook = Roo::Spreadsheet.open("#{Rails.root}/lib/tasks/data/#{agency[0]}")
      sheets = workbook.sheets
      issuing_agency = IssuingAgency.where("name = ?", agency[1]).first
      puts agency[1]
      issuing_agency_id = issuing_agency.id
      sheets.each do |sheet|
        patients = workbook.sheet(sheet)
        if sheet != "Tổng"
          month = sheet.split("Tháng ")[1].to_i
        end
        if patients.first_row
          patients.each_with_index do |patient, index|
            if index > 0 && !patient[0].nil? && !patient[1].nil? && !patient[2].nil?
              if patient[0] != "STT"
                patient_info = []
                identity_card_number = patient[10]
                if identity_card_number.instance_of? Float
                  identity_card_number = patient[10].to_i.to_s
                end
                code = patient[2]
                    
                name = patient[3]
                if name.present?
                  birthday = patient[4].to_date rescue DateTime.new(patient[4].to_i, 1, 1)
                  # gender = patient[4].squish == "Nam" ? "male" : "female" rescue nil
                  if patient[5]
                    gender = get_gender patient[5]
                  else
                    gender = "other"
                  end
                  jobs = patient[6].squish rescue nil
                  ethnicity_id = Ethnicity.find_by(name: patient[7].squish).id rescue nil
                  province_name = "%" + patient[16].squish + "%" rescue nil
                  district_name = "%" + patient[17].squish + "%" rescue nil
                  ward_name = "%" + patient[18].squish + "%" rescue nil
                  province_id = nil
                  province = Province.where("name like ?", province_name).first rescue nil
                  if province
                    province_id = province.id
                  end
                  districts = District.where("name like ?", district_name)
                  wards = Ward.where("name like ?", ward_name)
                  district_id = nil
                  if province_id
                    districts.each do |district|
                      if district.province.id == province_id
                        district_id = district.id
                      end
                    end
                  end
                  if district_id.nil? && province
                    district_id = province.districts.first.id
                  end
                  ward_id = nil
                  if district_id
                    wards.each do |ward|
                      if ward.district.id == district_id
                        ward_id = ward.id
                      end
                    end
                  end
                  if province_id.nil? && district_id.nil?
                    province_id = 1
                    district_id = 1
                  end
                  hamlet = patient[19].squish rescue nil
                  address = patient[15].squish rescue nil
                  mobile_phone = nil
                  id_card_number =  ward.district.code.to_s + issuing_agency.code.to_s + stt rescue nil

                  # marital_status = nil
                  # if patient[7].present?
                  #   marital_status = patient[7].squish
                  #   if marital_status.include? "Kết hôn"
                  #     marital_status = "married"
                  #   else
                  #     marital_status = "different"
                  #   end
                  # end

                  # education_level = "Difference"

                  # financial_status = nil
                  # if patient[12].present?
                  #   financial_status = patient[12].squish
                  # end

                  marital_status = nil
                  if patient[8].present?
                    marital_status = patient[8].squish
                    status = patient[8].squish
                    if status.include? "Đã kết hôn"
                      marital_status = "married"
                    elsif (status.include? "Chưa lập gia đình") || (status.include? "Độc thân")
                      marital_status = "single"
                    elsif (status.include? "Ly dị") || (status.include? "Ly hôn")
                      marital_status = "divorced"
                    elsif marital_status == "Chồng/Vợ đã mất"
                      marital_status = "widowed"
                    elsif marital_status == "Khác"
                      marital_status == "diference"
                    end
                  end

                  education_level = nil
                  if patient[9].present?
                    education_level = patient[9]
                    if education_level == "Cấp 1/Tiều học"
                      education_level = "Primary"
                    elsif education_level == "Cấp 2/ Trung học cơ sở"
                      education_level = "Middle"
                    elsif education_level == "Cấp 3/Trung học phổ thông"
                      education_level = "High"
                    elsif education_level == "Học nghề/Trung học/Cao đẳng/Đại học/…"
                      education_level = "Tertiary"
                    elsif education_level == "Khác"
                      education_level == "Difference"
                    elsif education_level == "Còn nhỏ"
                      education_level == "Children"
                    elsif education_level == "Mù chữ"
                      education_level == "Illiteracy"
                    end
                    check = education_level.to_date rescue nil
                    if check
                      education_level = check.month.to_s + "/" + check.day.to_s
                    end
                  end

                  financial_status = nil
                  if patient[13].present?
                    financial_status = patient[13]
                  end

                  admission_date = patient[14].to_date rescue nil
                  referral_agency = nil
                  issued_date = nil
                  identity_card_issued_date = patient[11].to_date rescue nil
                  identity_card_issued_by = patient[12]
                  health_insurance_code = nil
                  id_card_number =  issuing_agency.code.to_s rescue nil
                  info = patient[18].to_s + "  " + patient[17].to_s + "  " + patient[16].to_s
                  patient_contact_name = nil
                  if patient[20].present?
                   patient_contact_name = patient[20].squish
                  
                    patient_contact_address = nil
                    if patient[21].present?
                      patient_contact_address = patient[21].squish
                    end
                    patient_contact_phone = nil
                    if patient[22].present?
                      patient_contact_phone = patient[22]
                    end
                    patient_contact_type = nil
                    if patient[23].present?
                      patient_contact_type = patient[23].squish
                      if patient_contact_type == "Anh" || patient_contact_type == "Em" || patient_contact_type == "Chị" || 
                        (patient_contact_type == "anh") || (patient_contact_type == "em") || patient_contact_type == "chị"
                        patient_contact_type = 3
                      elsif (patient_contact_type == "Vợ") || (patient_contact_type == "Chồng") || (patient_contact_type == "vợ") || (patient_contact_type == "chồng")
                        patient_contact_type = 2
                      elsif patient_contact_type == "Bố" || patient_contact_type == "bố" || patient_contact_type == "cha" || patient_contact_type == "Cha"
                        patient_contact_type = 0
                      elsif patient_contact_type == "Mẹ" || patient_contact_type == "mẹ"
                        patient_contact_type = 1
                      elsif patient_contact_type == "con" || patient_contact_type == "Con"
                        patient_contact_type = 4
                      else
                        patient_contact_type = 5
                      end
                    end
                  end
                  patient_info << code << name << gender << birthday << jobs <<  ethnicity_id
                  patient_info << province_id << district_id << ward_id << hamlet
                  patient_info << address << mobile_phone << marital_status
                  patient_info << education_level << financial_status << admission_date 
                  patient_info << referral_agency << id_card_number << issued_date
                  patient_info << issuing_agency.id << identity_card_number << identity_card_issued_date
                  patient_info << identity_card_issued_by << health_insurance_code
                  patient_info << patient_contact_name << patient_contact_type << patient_contact_address << patient_contact_phone << month
                  25.upto(patient.length - 1) do |i|
                    patient_info << patient[i]
                  end
                  patients_list << patient_info
                end
              end
            end
          end
        end
      end
      patient_temp = []
      patients_list.each do |patient|
        if patient[20].nil? || patient[20] == 0 || patient == "0"
          patient_temp << patient
        end
      end
      patient_temp.each_with_index do |patient, index|
        if patient.length > 29
          temp = []
          0.upto(27) do |i|
            temp << patient[i]
          end
          patient_temp[index] = temp
        end
      end
      medicine_allocations = []
      patients_list.each_with_index do |patient, index|
        medicine_allocation = []
        medicine_allocation << patient[0]
        medicine_allocation << patient[20]
        if patient.length > 29
          28.upto(patient.length - 1) do |i|
            medicine_allocation << patient[i]
          end
          temp = []
          0.upto(27) do |i|
            temp << patient[i]
          end
          patients_list[index] = temp
        end
        medicine_allocations << medicine_allocation
      end
      patients_list = patients_list.uniq{|x| x[20]}
      patients_list = patients_list + patient_temp
      patients_list = patients_list.uniq{|x| x[0]}
      medicine_allocations.each do |medicine_allocation|
        patients_list.each_with_index do |patient, index|
          if !medicine_allocation[1].nil? || medicine_allocation[1] == "0" || medicine_allocation[1] == 0
            if medicine_allocation[1] == patient[20]
              patients_list[index] << medicine_allocation
            end
          elsif medicine_allocation[0] == patient[0]
              patients_list[index] << medicine_allocation
          end
        end
      end
      patients_list.each_with_index do |patient, index|
        if patient_stt > 0
          tmp = patient_stt + 1
          stt = "0"*(5 - tmp.to_s.length) + tmp.to_s
        else
          stt = "00001"
        end
      if patient[20].nil? || patient[20] == "0" || patient[20] == 0
        if identity_card_number_fake > 0
          tmp = identity_card_number_fake + 1
          identity_card_number  = "0"*(13 - tmp.to_s.length) + tmp.to_s
        else
          identity_card_number = "0000000000000"
        end
        identity_card_number_fake += 1
      end
      patients_list[index] << patient_stt + 1
      patient_stt += 1
      id_card_number = patient[17] + stt
      puts id_card_number
      Patient.create! name: patient[1], gender: patient[2], birthdate: patient[3],
        jobs: patient[4], ethnicity_id: patient[5], province_id: patient[6],
        district_id: patient[7], ward_id: patient[8], hamlet: patient[9],
        address: patient[10], mobile_phone: patient[11], marital_status: patient[12],
        education_level: patient[13], financial_status: patient[14],
        admission_date: patient[15].nil? ? Time.now : patient[15], referral_agency: patient[16].nil? ? "Chưa có" : patient[16],
        card_number: id_card_number, issued_date: patient[18],
        issuing_agency_id: patient[19], identification_number: patient[20].nil? ? identity_card_number : patient[20],
        identification_issued_date: patient[21].nil? ? Time.now : patient[21],
        identification_issued_by: patient[22].nil? ? "Không có" : patient[22],
        health_insurance_code: patient[23], identification_type: 0
      end
      PatientContact.bulk_insert do |work|
        patients_list.each_with_index do |patient|
          if patient[24] || patient[25] || patient[26] || patient[27]
            length = patient.length
            patient_id = patient[length - 1]
            work.add name: patient[24], contact_type: patient[25], address: patient[26],
                  telephone: patient[27], patient_id: patient_id
          end
        end
      end

      user_id = issuing_agency.users.nurse.first.id
      MedicineAllocation.bulk_insert do |work|
        patients_list.each_with_index do |patient_allo|
          length = patient_allo.length
          patient_id = patient_allo[length - 1]
          if patient_allo.length > 28
            28.upto(patient_allo.length - 2) do |i|
              start_day = DateTime.new(2017, patient_allo[i][2].to_i, 1) rescue nil
              temp = patient_allo[i].length rescue nil
              if temp
                3.upto(temp - 1) do |k|
                  if patient_allo[i][k]
                    dosage = patient_allo[i][k]
                    if dosage.instance_of? String
                      if dosage.include? "mg"
                        dosage = dosage.squish
                        dosage = dosage.split("mg")[0].to_f
                      end
                    end
                    dosage = dosage.to_f
                  end
                  if dosage != 0 && dosage
                    work.add(patient_id: patient_id,
                        allocation_date: start_day, user_id: user_id, dosage: dosage,
                        status: MedicineAllocation.statuses[:taked])
                  end
                  start_day = start_day + 1.days
                end
              end
            end
          end
        end
      end
    end
  end
end
