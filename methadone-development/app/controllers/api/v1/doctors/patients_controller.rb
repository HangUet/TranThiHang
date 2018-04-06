class Api::V1::Doctors::PatientsController < ApplicationController
  require "rubyXL"

  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    today = Date.today
    if @current_user.role == "admin"
      @patients = Patient.actived.select(:id, :name, :mobile_phone, :card_number, :identification_number,
        :gender, :birthdate, :admission_date, :address)
        .search(name_or_card_number_cont: params[:keyword]).result
        .paginate(:page => params[:page], :per_page => Settings.per_page).order(card_number: :desc)
    else
      @patients = Patient.actived.select(:id, :name, :mobile_phone, :card_number, :identification_number,
        :gender, :birthdate, :admission_date, :address)
        .where(issuing_agency_id: @current_user.issuing_agency_id)
        .search(name_or_card_number_cont: params[:keyword]).result
        .paginate(:page => params[:page], :per_page => Settings.per_page).order(card_number: :desc)
    end

  end

  def search
    if @current_user.role == "admin"
      if params[:patient][:agency]
        search_patient params[:patient][:agency], 1
      else
        search_patient_without_issuing_agency 1
      end
    else
      search_patient @current_user.issuing_agency_id, 1
    end
    @patients = @patients.paginate page: params[:page], per_page: Settings.per_page
    if params[:patient][:status] != "sent"
      render json: {data: @patients, per_page: Settings.per_page,
        page: params[:page], total: @patients.total_entries, message: t("common.success"), code: 1}
    elsif params[:patient][:status] == "sent"
      render json: {data: @patients, per_page: Settings.per_page,
        page: params[:page], total: @patients.total_entries, message: t("common.success"), code: 1, sent: 1}
    end
  end

  def search_and_export
    if @current_user.role == "admin"
      if params[:patient][:agency]
        search_patient params[:patient][:agency], 0
      else
        search_patient_without_issuing_agency 0
      end
    else
      search_patient @current_user.issuing_agency_id, 0
    end
    # @patients = Patient.all
    respond_to do |format|
      format.xlsx do
        send_data export_excel(@patients)
        return
      end
    end
  end

  private

  def search_patient issuing_agency_id, paginate
    if params[:patient][:status] != "sent"
      @patients = Patient.where(issuing_agency_id: issuing_agency_id)
                         .not_deleted.order(card_number: :desc)
    else
      @patients = Patient.not_deleted.order(card_number: :desc)
                         .joins(:patient_agency_histories).where("sender_agency_id = ?", issuing_agency_id)
      if params[:patient][:status_from].present? || params[:patient][:status_to].present?
        @patients =  @patients.where("patient_agency_histories.status = 2").ransack(
          patient_agency_histories_date_accepted_gteq: params[:patient][:status_from].to_datetime,
          patient_agency_histories_date_accepted_lteq: (params[:patient][:status_to].to_date.end_of_day rescue nil)).result
      else
        @patients = @patients.joins(:stop_treatment_histories)
      end
    end
    if params[:patient][:treatment_status].present?
      if params[:patient][:treatment_status] == "expirate_prescription"
        prescriptions = Prescription.where(patient_id: @patients.pluck(:id)).joins(:patient)
        .select("prescriptions.*, patients.*").group_by(&:patient_id).values

        list_patients = []
        #Truong hop benh nhan co don trong tuong lai 
        two_prescription = Prescription.where(patient_id: @patients.where("patients.id in (SELECT patient_id FROM `prescriptions` 
                              WHERE close_status = 1 
                              and prescription_type != 'temp_day' 
                              and prescription_type != 'temp_morning' 
                              and prescription_type != 'temp_afternoon'
                              GROUP BY patient_id 
                              HAVING COUNT(patient_id) > 1)"))
                              .group_by(&:patient_id).values
        
        list_patient_with_two_pres = [] #Danh sach benh nhan co don trong tuong lai

        two_prescription.each do |prescriptions|
          list_patient_with_two_pres << prescriptions[0].patient_id
          if prescriptions[0].end_date_expected < prescriptions[1].begin_date &&
            prescriptions[0].end_date_expected.to_date >=  params[:patient][:treatment_status_from].to_date &&
            prescriptions[0].end_date_expected.to_date <= params[:patient][:treatment_status_to].to_date
            list_patients << prescriptions[0].patient_id
          end
          if prescriptions[0].end_date_expected >= prescriptions[1].begin_date &&
            prescriptions[1].end_date_expected.to_date >=  params[:patient][:treatment_status_from].to_date &&
            prescriptions[1].end_date_expected.to_date <= params[:patient][:treatment_status_to].to_date
            list_patients << prescriptions[0].patient_id
          end
        end
        # Danh sach benh nhan 1 don hoac ko co don
        patient_one_prescription = @patients.where(id: @patients.pluck(:id) - list_patient_with_two_pres)
                                     .joins(:prescriptions)
                                     .where("(DATE(end_date_expected) <= ? and DATE(end_date_expected) >= ?)
                                        or (DATE(end_date) <= ? and DATE(end_date) >= ?) and prescription_type != 'temp_day'
                                        and prescription_type != 'temp_morning' and prescription_type != 'temp_afternoon'",
                                        params[:patient][:treatment_status_to].to_date, params[:patient][:treatment_status_from].to_date,
                                        params[:patient][:treatment_status_to].to_date, params[:patient][:treatment_status_from].to_date)
                                        .pluck(:id)

        @patients = Patient.where(id: patient_one_prescription + list_patients)
        

      elsif params[:patient][:treatment_status] == "give_up_medicine"
        @patients = @patients.ransack(
          medicine_allocations_allocation_date_lt: Date.today.to_datetime,
          medicine_allocations_status_eq: MedicineAllocation.statuses[:waiting],
          medicine_allocations_notify_status_eq: MedicineAllocation.notify_statuses[:not_fall]).result
      else
        @patients = @patients.actived
      end
    end
    if params[:patient][:type_address] == "household"
      @patients = @patients.ransack(province_id_eq: params[:patient][:province_id],
          district_id_eq: params[:patient][:district_id],
          ward_id_eq: params[:patient][:ward_id]).result
    elsif  params[:patient][:type_address] == "resident_address"
      @patients = @patients.ransack(resident_province_id_eq: params[:patient][:province_id],
          resident_district_id_eq: params[:patient][:district_id],
          resident_ward_id_eq: params[:patient][:ward_id]).result
    end
    @patients = @patients.ransack(identification_type_eq: params[:patient][:identification_type],
      identification_number_cont: params[:patient][:identification_number],
      jobs_eq: params[:patient][:jobs],
      birthdate_gteq: params[:patient][:birthdate_from].to_datetime,
      birthdate_lteq: (params[:patient][:birthdate_to].to_date.end_of_day rescue nil),
      admission_date_gteq: params[:patient][:admission_date_from].to_datetime,
      admission_date_lteq: (params[:patient][:admission_date_to].to_date.end_of_day rescue nil),
      name_cont: params[:patient][:name],
      marital_status_eq: params[:patient][:marital_status],
      education_level_eq: params[:patient][:education_level],
      financial_status_eq: params[:patient][:financial_status],
      ethnicity_id_eq: params[:patient][:ethnicity_id],
      prescriptions_type_treatment_eq: params[:patient][:prescription_status],
      prescriptions_close_status_eq: params[:patient][:prescription_status].blank? ? nil : 1).result

    if paginate == 1
      @patients = @patients.paginate page: params[:page], per_page: Settings.per_page
    end

    if (params[:patient][:status]) == "deactived"
      if params[:patient][:status_from].present? || params[:patient][:status_to].present?
        @patients = @patients.ransack(
          stop_treatment_histories_stop_time_gteq: params[:patient][:status_from].to_datetime,
          stop_treatment_histories_stop_time_lteq: (params[:patient][:status_to].to_date.end_of_day rescue nil)).result
      else
        @patients = @patients.deactived
      end
    elsif (params[:patient][:status]) == "reiceved"
      if params[:patient][:status_from].present? || params[:patient][:status_to].present?
      @patients = @patients.ransack(
        patient_agency_histories_receiver_agency_id: issuing_agency_id,
        patient_agency_histories_date_accepted_gteq: params[:patient][:status_from].to_datetime,
        patient_agency_histories_date_accepted_lteq: (params[:patient][:status_to].to_date.end_of_day rescue nil)).result
      else
        @patients = @patients.joins(:patient_agency_histories).where("receiver_agency_id = ?",  issuing_agency_id)
      end
    elsif (params[:patient][:status] == "treatmenting")
      patient_now = @patients.pluck(:id)
      patient_give_up = @patients.joins("left join stop_treatment_histories on stop_treatment_histories.patient_id = patients.id")
        .where("(return_time < ? and return_time > ? or return_time is NULL) and
        DATE(stop_time) >= ? and DATE(stop_time) <= ?", params[:patient][:status_from].to_date,
        params[:patient][:status_to].to_date,params[:patient][:status_from].to_date,
        params[:patient][:status_to].to_date).pluck(:id)
      @patients = Patient.where(id: (patient_now - patient_give_up))
    end
    @patients = @patients.distinct
  end

  def search_patient_without_issuing_agency paginate
    if params[:patient][:status] != "sent"
      @patients = Patient.not_deleted.order(card_number: :desc)
    else
      render json: {code: 2, message: "Bạn phải chọn cơ sở" }
    end
    if params[:patient][:treatment_status].present?
      if params[:patient][:treatment_status] == "expirate_prescription"
        @patients = @patients.joins(:prescriptions).where("(DATE(end_date_expected) <= ? and DATE(end_date_expected) >= ?)
        or (DATE(end_date) <= ? and DATE(end_date) >= ?) and prescription_type != 'temp'",
        params[:patient][:treatment_status_to].to_date, params[:patient][:treatment_status_from].to_date,
        params[:patient][:treatment_status_to].to_date, params[:patient][:treatment_status_from].to_date)
      elsif params[:patient][:treatment_status] == "give_up_medicine"
        @patients = @patients.ransack(
          medicine_allocations_allocation_date_lt: Date.today.to_datetime,
          medicine_allocations_status_eq: MedicineAllocation.statuses[:waiting],
          medicine_allocations_notify_status_eq: MedicineAllocation.notify_statuses[:not_fall]).result
      else
        @patients = @patients.actived
      end
    end
    if params[:patient][:type_address] == "household"
      @patients = @patients.ransack(province_id_eq: params[:patient][:province_id],
          district_id_eq: params[:patient][:district_id],
          ward_id_eq: params[:patient][:ward_id]).result
    elsif  params[:patient][:type_address] == "resident_address"
      @patients = @patients.ransack(resident_province_id_eq: params[:patient][:province_id],
          resident_district_id_eq: params[:patient][:district_id],
          resident_ward_id_eq: params[:patient][:ward_id]).result
    end
    @patients = @patients.ransack(identification_type_eq: params[:patient][:identification_type],
      identification_number_cont: params[:patient][:identification_number],
      jobs_eq: params[:patient][:jobs],
      birthdate_gteq: params[:patient][:birthdate_from].to_datetime,
      birthdate_lteq: (params[:patient][:birthdate_to].to_date.end_of_day rescue nil),
      admission_date_gteq: params[:patient][:admission_date_from].to_datetime,
      admission_date_lteq: (params[:patient][:admission_date_to].to_date.end_of_day rescue nil),
      name_cont: params[:patient][:name],
      marital_status_eq: params[:patient][:marital_status],
      education_level_eq: params[:patient][:education_level],
      financial_status_eq: params[:patient][:financial_status],
      ethnicity_id_eq: params[:patient][:ethnicity_id]).result

    if paginate == 1
      @patients = @patients.paginate page: params[:page], per_page: Settings.per_page
    end

    if (params[:patient][:status]) == "deactived"
      if params[:patient][:status_from].present? || params[:patient][:status_to].present?
        @patients = @patients.ransack(
          stop_treatment_histories_stop_time_gteq: params[:patient][:status_from].to_datetime,
          stop_treatment_histories_stop_time_lteq: (params[:patient][:status_to].to_date.end_of_day rescue nil)).result
      else
        @patients = @patients.deactived
      end
    elsif (params[:patient][:status]) == "reiceved"
      @patients = @patients.ransack(
        patient_agency_histories_receiver_agency_id: current_user.issuing_agency_id,
        patient_agency_histories_date_accepted_gteq: params[:patient][:status_from].to_datetime,
        patient_agency_histories_date_accepted_lteq: (params[:patient][:status_to].to_date.end_of_day rescue nil)).result
    elsif (params[:patient][:status] == "treatmenting")
      @patients = @patients.joins("left joins stop_treatment_histories on 
        (DATE(return_time) => ? and DATE(return_time) <= ?)", params[:patient][:status_from].to_date,
        params[:patient][:status_to].to_date)
    end
    @patients = @patients.distinct
  end

  def export_excel patients
    workbook = RubyXL::Parser.parse("#{Rails.root}/public/template_excel/DanhSach.xlsx")
    worksheet = workbook[0]
    patients.each_with_index do |patient, index|
      worksheet.insert_row(index + 2)

      issuing_agency = patient.issuing_agency.name rescue nil
      birthdate = patient.birthdate.strftime "%d/%m/%Y" rescue nil
      gender = patient.gender == "male" ? "Nam" : "Nữ"
      ethnicity = patient.ethnicity.name rescue nil
      marital_status = patient.marital_status
      education_level = patient.education_level
      identification_type = patient.identification_type ? I18n.t("patients.#{patient.identification_type}") : nil
      identification_number = patient.identification_number
      identification_issued_date = patient.identification_issued_date.strftime "%d/%m/%Y" rescue nil
      identification_issued_by = patient.identification_issued_by
      financial_status = patient.financial_status
      admission_date = patient.admission_date.strftime "%d/%m/%Y" rescue nil
      province = patient.province.name rescue nil
      district = patient.district.name rescue nil
      ward = patient.ward.name rescue nil
      hamlet = patient.hamlet rescue ""
      address = patient.address
      resident_province = patient.resident_province.name rescue nil
      resident_district = patient.resident_district.name rescue nil
      resident_ward = patient.resident_ward.name rescue nil
      resident_hamlet = patient.resident_hamlet rescue ""
      resident_address = patient.resident_address
      patient_contact_name = patient.patient_contacts.first.name rescue nil
      patient_contact_address = patient.patient_contacts.first.address rescue nil
      patient_contact_telephone = patient.patient_contacts.first.telephone rescue nil
      tmp = patient.patient_contacts.first.contact_type rescue nil
      patient_contact_type = tmp ? I18n.t("patients.#{tmp}") : nil

      prescription = Prescription.type_treatment_of_patient(patient.id)

      status = prescription.present? ? I18n.t("patients.#{prescription[0].type_treatment}") : nil

      active_content = patient.active

      if active_content == "deactived"
        date_stop = patient.stop_treatment_histories.last.stop_time.strftime "%d/%m/%Y" rescue nil
      else
        date_stop = nil
      end

      patient_history = PatientAgencyHistory.where(patient_id: patient.id, status: 2).
        where("sender_agency_id = ? or receiver_agency_id = ?", @current_user.issuing_agency_id,
          @current_user.issuing_agency_id).last rescue nil

      date_send = nil
      date_received = nil

      if patient_history.present?
        if patient_history.sender_agency_id == @current_user.issuing_agency_id
          active_content = "sent"
          date_send = patient_history.date_accepted.strftime "%d/%m/%Y" rescue nil
        else
          active_content = "reiceved"
          date_received = patient_history.date_accepted.strftime "%d/%m/%Y" rescue nil
        end
      end

      active = active_content.present? ? I18n.t("patients.#{active_content}") : nil

      index_row = index + 2

      worksheet.add_cell(index_row, 0, "#{index + 1}")
      worksheet.add_cell(index_row, 1, "#{issuing_agency}")
      worksheet.add_cell(index_row, 2, "#{patient.card_number}")
      worksheet.add_cell(index_row, 3, "#{patient.name}")
      worksheet.add_cell(index_row, 4, "#{birthdate}")
      worksheet.add_cell(index_row, 5, "#{gender}")
      worksheet.add_cell(index_row, 6, "#{patient.jobs}")
      worksheet.add_cell(index_row, 7, "#{ethnicity}")
      worksheet.add_cell(index_row, 8, "#{marital_status}")
      worksheet.add_cell(index_row, 9, "#{education_level}")
      worksheet.add_cell(index_row, 10, "#{identification_type}")
      worksheet.add_cell(index_row, 11, "#{identification_number}")
      worksheet.add_cell(index_row, 12, "#{identification_issued_date}")
      worksheet.add_cell(index_row, 13, "#{identification_issued_by}")
      worksheet.add_cell(index_row, 14, "#{financial_status}")
      worksheet.add_cell(index_row, 15, "#{admission_date}")

      worksheet.add_cell(index_row, 16, "#{province}")
      worksheet.add_cell(index_row, 17, "#{district}")
      worksheet.add_cell(index_row, 18, "#{ward}")
      worksheet.add_cell(index_row, 19, "#{hamlet}")
      worksheet.add_cell(index_row, 20, "#{address}")

      worksheet.add_cell(index_row, 21, "#{resident_province}")
      worksheet.add_cell(index_row, 22, "#{resident_district}")
      worksheet.add_cell(index_row, 23, "#{resident_ward}")
      worksheet.add_cell(index_row, 24, "#{resident_hamlet}")
      worksheet.add_cell(index_row, 25, "#{resident_address}")

      worksheet.add_cell(index_row, 26, "#{patient_contact_name}")
      worksheet.add_cell(index_row, 27, "#{patient_contact_address}")
      worksheet.add_cell(index_row, 28, "#{patient_contact_telephone}")
      worksheet.add_cell(index_row, 29, "#{patient_contact_type}")
      worksheet.add_cell(index_row, 30, "#{status}")
      worksheet.add_cell(index_row, 31, "#{active}")
      worksheet.add_cell(index_row, 32, "#{date_stop}")
      worksheet.add_cell(index_row, 33, "#{date_send}")
      worksheet.add_cell(index_row, 34, "#{date_received}")
    end
    workbook.stream.string
  end
end
