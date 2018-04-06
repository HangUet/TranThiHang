class Api::V1::PatientsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    all_patients = Patient.not_deleted
      .where(issuing_agency_id: @current_user.issuing_agency_id).pluck(:id) rescue []

    patient_taked_medicine = Patient.not_deleted
      .joins("inner join prescriptions on prescriptions.patient_id = patients.id")
      .joins("inner join medicine_allocations on medicine_allocations.prescription_id = prescriptions.id")
      .where(issuing_agency_id: @current_user.issuing_agency_id)
      .where("status = 2 and DATE(allocation_date) = ?", Date.today)
      .distinct.pluck(:id)

    patient_wont_take_medicine = Patient.not_deleted
      .joins("inner join prescriptions on prescriptions.patient_id = patients.id")
      .joins("inner join medicine_allocations on medicine_allocations.prescription_id = prescriptions.id")
      .where(issuing_agency_id: @current_user.issuing_agency_id)
      .where("status != 2 and DATE(allocation_date) = ? and notify_status = 0", Date.today)
      .distinct.pluck(:id)

    patient_taked_medicine = patient_taked_medicine.reject {|w| patient_wont_take_medicine.include? w}

    patient_medicine_allocation = all_patients - patient_taked_medicine

    @patients = Patient.not_deleted.where(id: patient_medicine_allocation)
      .search(name_or_card_number_cont: params[:keyword]).result
      .paginate :page => params[:page], :per_page => Settings.per_page

    render json: {data: @patients, per_page: Settings.per_page,
      page: params[:page], total: @patients.total_entries, message: t("common.success")}
  end

  def show
    @patient = Patient.not_deleted.where(id: params[:id]).first
    if !@patient
      render json: {code: 2, message: t("common.fail")}
    else
      @prescription = Prescription.where(patient_id: params[:id]).last
      give_up_two_times_in_day = MedicineAllocation.waiting
        .where("DATE(allocation_date) < ? and patient_id = ? and notify_status = ?",
        Date.today, params[:id], MedicineAllocation.notify_statuses[:not_fall])
        .having("count(allocation_date) = 2").pluck(:allocation_date, :typee)

      give_up_one_time_in_day = MedicineAllocation.waiting
        .where("DATE(allocation_date) < ? and patient_id = ? and notify_status = ?",
        Date.today, params[:id], MedicineAllocation.notify_statuses[:not_fall])
        .having("count(allocation_date) = 1").pluck(:allocation_date, :typee)
      give_up_day = ""
      if give_up_one_time_in_day.present?
        all_day =  give_up_one_time_in_day.map {|date, type| [(date.strftime "%d/%m/%Y"), type_to_text(type)]}
        length = all_day.length
        all_day.each_with_index do |day, index|
          if day[1]
            give_up_day += day[0].to_s + day[1].to_s
            if index < length - 1
              give_up_day += ", "
            end
          else
            give_up_day += day[0].to_s
            if index < length - 1
              give_up_day += ", "
            end
          end
        end
      end

      if give_up_two_times_in_day.present?
        all_day =  give_up_two_times_in_day.map {|date, type| [(date.strftime "%d/%m/%Y"), type]}
        length = all_day.length
        all_day.each_with_index do |day, index|
          give_up_day += day[0].to_s
          if index < length - 1
            give_up_day += ", "
          end
        end
      end

      if give_up_day.present?
        @notifi = "Bỏ thuốc các ngày: #{give_up_day}"
      else
        @notifi = "Điều trị đầy đủ"
      end
    end
  end

  def get_by_barcode
    @patient = Patient.select(:id).find_by_id_card_number(params[:barcode])
    if @patient
      render json: {code: 1, message: t("common.success"), data: @patient}
    else
      render json: {code: 2, message: "Mã bệnh nhân không đúng"}
    end
  end

  def get_change_dosage
    @issuing_agency_id = @current_user.issuing_agency_id
    @patients_change = []
    data = []
    if params[:date]
      @day = params[:date].split("/")[0]
      @month = params[:date].split("/")[1]
      @year = params[:date].split("/")[2]
      init_change_dosage(@day.to_i, @month, @year, data)
    else
      init_change_dosage(Time.now.day, Time.now.month, Time.now.year, data)
    end
    render json: {code: 1, data: data}
  end

  def create
    patient = Patient.new(patient_params)
    patient.issuing_agency_id = @current_user.issuing_agency_id

    patient_sequence = PatientSequence.where(issuing_agency_id: @current_user.issuing_agency_id).first
    card_number = patient_sequence.number.to_i + 1
    patient.card_number = IssuingAgency.find(@current_user.issuing_agency_id).code.to_s + card_number.to_s.rjust(5, '0')
    if params[:patient][:same_patient].present? || (params[:patient][:same_patient].blank? && !check_same_patient("create", patient))
      if patient.save
        if params[:patient][:contacts].present?
          params[:patient][:contacts].each do |contact|
            PatientContact.create(name: contact[:name], contact_type: contact[:contact_type], address: contact[:address],
                                  telephone: contact[:telephone], patient_id: patient.id)
          end
        end
        patient_sequence.update_attributes number: patient_sequence.number + 1
        render json: {code: 1, message: t("patients.create.success"), id: patient.id}
      else
        if !check_same_patient("create", patient)
          message = ""
          patient.errors.full_messages.each do |e|
            message = message + e + ". "
          end
          render json: {code: 2, message: message}
        end
      end
    end
  end

  def search_by_nurse
    if params[:patient][:status] == 0
      search_when_waiting params[:patient][:allocation_date_from], params[:patient][:allocation_date_to], 1
    else
      search_not_wait 1
    end

    render json: {data: @patients, per_page: Settings.per_page,
      page: params[:page], total: @patients.total_entries, message: t("common.success"), code: 1}
  end

  def search_and_export
    if params[:patient][:status] == 0
      search_when_waiting params[:patient][:allocation_date_from], params[:patient][:allocation_date_to], 0
    else
      search_not_wait 0
    end

    respond_to do |format|
      format.xlsx do
        send_data export_excel(@patients)
        return
      end
    end
  end

  def update
    patient = Patient.find_by id: params[:id]
    check_agency = PatientAgencyHistory.pending.find_by patient_id: params[:id]
    if check_agency.blank?
      if params[:patient][:same_patient].present? || (params[:patient][:same_patient].blank? && !check_same_patient("update", patient))
        if patient.update_attributes patient_params
          removed_contact_ids = PatientContact.where(patient_id: params[:id]).pluck(:id) - params[:patient][:contacts].map{|x| x[:id]}.compact rescue []
          PatientContact.where(id: removed_contact_ids).delete_all

          if params[:patient][:contacts].present?
            params[:patient][:contacts].each do |contact|
              if contact[:id].blank?
                PatientContact.create(name: contact[:name], contact_type: contact[:contact_type], address: contact[:address],
                                    telephone: contact[:telephone], patient_id: patient.id)
              else
                patient_contact = PatientContact.find_by_id(contact[:id])
                patient_contact.update_attributes(name: contact[:name], contact_type: contact[:contact_type],
                  address: contact[:address], telephone: contact[:telephone], patient_id: patient.id)
              end
            end
          end
          render json: {code: 1, message: t("patients.update.success"), id: patient.id}
        else
          message = ""
          patient.errors.full_messages.each do |e|
            message = message + e + ". "
          end
          render json: {code: 2, message: message}
        end
      end
    else
      render json: {code: 2, message: "Bệnh nhân đang chờ chuyển cơ sở"}
    end
  end

  def destroy
    patient = Patient.find_by id: params[:id], issuing_agency_id: @current_user.issuing_agency_id
    patient_change_agency = PatientAgencyHistory.find_by patient_id: patient.id
    if @current_user.role == "admin_agency"
      if patient_change_agency.blank?
        delete_patient patient
      else
        if patient_change_agency.confirmer_id.present?
          render json: {code: 2, message: "Không thể xóa bệnh nhân chuyển đến từ cơ sở khác"}
        elsif patient_change_agency.pending?
          render json: {code: 2, message: "Không thể xóa bệnh nhân đang chờ chuyển đến cơ sở khác"}
        else
          receiver_doctors = User.doctor.where(issuing_agency_id: patient_change_agency.receiver_agency_id)
          receiver_doctors.each do |doctor|
            notification = Notification.find_by user_id: doctor.id
            notification.destroy
          end
          delete_patient patient
        end
      end
    else
      render json: {code: 2, message: ""}
    end
  end

  def get_list_patient_revoke
    if params[:page].blank?
      params[:page] = 1
    else
      params[:page] = params[:page].to_i
    end
    if params[:card_number].present?
      params[:card_number] = "%" + params[:card_number] + "%"
    end
    if params[:name].present?
      params[:name] = "%" + params[:name] + "%"
    end
    if params[:from_date].present? && params[:to_date].blank?
      @history_falled = MedicineAllocation.joins(:user)
        .joins(:patient).select('medicine_allocations.*').select(:name, :card_number, :patient_id)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("DATE(allocation_date) >= ?", params[:from_date].to_date)
        .where("notify_status = 0 and status = 0")
        .where("(:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number)",
              {
                name: params[:name],
                card_number: params[:card_number],
              })
        .distinct(:patient_id)
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:from_date].blank? && params[:to_date].present?
      @history_falled = MedicineAllocation.joins(:user)
        .joins(:patient).select('medicine_allocations.*').select(:name, :card_number, :patient_id)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("DATE(allocation_date) <= ?", params[:to_date].to_date)
        .where("notify_status = 0 and status = 0")
        .where("(:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number)",
              {
                name: params[:name],
                card_number: params[:card_number],
              })
        .group(:patient_id)
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:from_date].present? && params[:to_date].present?
      @history_falled = MedicineAllocation.joins(:user)
        .joins(:patient).select('medicine_allocations.*').select(:name, :card_number, :patient_id)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("DATE(allocation_date) <= ? and DATE(allocation_date) >= ?", params[:to_date].to_date, params[:from_date].to_date)
        .where("notify_status = 0 and status = 0")
        .where("(:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number)",
              {
                name: params[:name],
                card_number: params[:card_number],
              })
        .group(:patient_id)
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:from_date].blank? && params[:to_date].blank?
      @history_falled = MedicineAllocation.joins(:user)
        .joins(:patient)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("notify_status = 0 and status = 0")
        .where("DATE(allocation_date) < ?", Date.today)
        .where("(:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number)",
              {
                name: params[:name],
                card_number: params[:card_number],
              })
        .select('medicine_allocations.*').select(:name, :card_number, :patient_id)
        .group(:patient_id)
        .paginate page: params[:page], per_page: Settings.per_page
    end

    render json: {code: 1, message: "success", data: @history_falled, total: @history_falled.total_entries,
      per_page: Settings.per_page, page: params[:page]}
  end

  def get_time_drop_medicine
    @prescription = Prescription.where(patient_id: params[:patient_id]).last
      give_up_two_times_in_day = MedicineAllocation.waiting
        .where("DATE(allocation_date) < ? and patient_id = ? and notify_status = ?",
        Date.today, params[:patient_id], MedicineAllocation.notify_statuses[:not_fall])
        .having("count(allocation_date) = 2").pluck(:allocation_date, :typee)

      give_up_one_time_in_day = MedicineAllocation.waiting
        .where("DATE(allocation_date) < ? and patient_id = ? and notify_status = ?",
        Date.today, params[:patient_id], MedicineAllocation.notify_statuses[:not_fall])
        .having("count(allocation_date) = 1").pluck(:allocation_date, :typee)
      give_up_day = ""
      if give_up_one_time_in_day.present?
        all_day =  give_up_one_time_in_day.map {|date, type| [(date.strftime "%d/%m/%Y"), type_to_text(type)]}
        length = all_day.length
        all_day.each_with_index do |day, index|
          if day[1]
            give_up_day += day[0].to_s + day[1].to_s
            if index < length - 1
              give_up_day += ", "
            end
          else
            give_up_day += day[0].to_s
            if index < length - 1
              give_up_day += ", "
            end
          end
        end
      end

      if give_up_two_times_in_day.present?
        all_day =  give_up_two_times_in_day.map {|date, type| [(date.strftime "%d/%m/%Y"), type]}
        length = all_day.length
        all_day.each_with_index do |day, index|
          give_up_day += day[0].to_s
          if index < length - 1
            give_up_day += ", "
          end
        end
      end

      render json: {code: 1, data: give_up_day}

  end

  private

  def patient_params
    params.require(:patient).permit :name, :gender, :birthdate, :jobs,
      :ethnicity_id, :mobile_phone, :marital_status, :education_level,
      :province_id, :district_id, :ward_id, :hamlet, :address, :financial_status,
      :admission_date, :referral_agency, :identification_type, :identification_number,
      :identification_issued_date, :identification_issued_by, :avatar, :resident_province_id,
      :resident_district_id, :resident_ward_id, :resident_hamlet, :resident_address
  end

  def init_change_dosage(day, month, year, data)
    @patients = Patient.where(issuing_agency_id: current_user.issuing_agency_id)
    @patients.each do |patient|
      patient_allocation_today = patient.medicine_allocations.allocated
                                    .where("DAY(allocation_date) = #{day}
                                    and MONTH(allocation_date) = #{month} and YEAR(allocation_date) = #{year}")
                                    .sum(:dosage)
      patient_allocation_yesterday = patient.medicine_allocations.allocated.allocate_before(day -1, month, year).sum(:dosage)
      increase = patient_allocation_yesterday < patient_allocation_today ? patient_allocation_today - patient_allocation_yesterday : 0
      decrease = patient_allocation_yesterday > patient_allocation_today ? patient_allocation_yesterday - patient_allocation_today : 0
      first_date_allocation = patient.medicine_allocations.allocated.first.allocation_date rescue 0
      beginn = patient.medicine_allocations.allocated.where("DATE(allocation_date) = ?", first_date_allocation).sum(:dosage)
      if patient_allocation_today != patient_allocation_yesterday
        data.push({card_number: patient.card_number,
                  name: patient.name,
                  before_dosage: patient_allocation_yesterday,
                  dosage: patient_allocation_today,
                  increase: increase,
                  decrease: decrease,
                  beginn: beginn})
      end
    end
  end

  def search_when_waiting allocate_from, allocate_to, paginate
    today = Date.today
    @patients = Patient.where(issuing_agency_id: @current_user.issuing_agency_id)
    if params[:patient][:type_address] == "household"
      @patients = @patients.ransack(province_id_eq: params[:patient][:province_id],
          district_id_eq: params[:patient][:district_id],
          ward_id_eq: params[:patient][:ward_id]).result
    elsif  params[:patient][:type_address] == "resident_address"
      @patients = @patients.ransack(resident_province_id_eq: params[:patient][:province_id],
          resident_district_id_eq: params[:patient][:district_id],
          resident_ward_id_eq: params[:patient][:ward_id]).result
    end
    if allocate_from.blank? && allocate_to.blank?
      @patient_have_prescription = @patients.joins(:prescriptions)
      .where("DATE(begin_date) <= ? and DATE(end_date) >= ?", today, today)
      .pluck(:id) rescue []
    elsif allocate_to.present? && allocate_from.blank?
      @patient_have_prescription = @patients.joins(:prescriptions)
      .where("DATE(begin_date) <= ? and DATE(end_date) >= ?", allocate_from.to_date, allocate_from.to_date)
      .pluck(:id) rescue []
    elsif allocate_to.blank? && allocate_from.present?
      @patient_have_prescription = @patients.joins(:prescriptions)
      .where("DATE(begin_date) >= ?", allocate_from.to_date)
      .pluck(:id) rescue []
    else
      @patient_have_prescription = @patients.joins(:prescriptions)
      .where("DATE(begin_date) >= ? and DATE(end_date) <= ?", allocate_from.to_date, allocate_to.to_date)
      .pluck(:id) rescue []
    end
    # byebug
    @patient_allocated = @patients.joins(:medicine_allocations)
      .where("status != 0 and DATE(allocation_date) = ?",
        Date.today).pluck(:id) rescue []
    @patients = Patient.order(card_number: :desc)
                       .not_deleted
                       .where(id: @patient_have_prescription - @patient_allocated)
                       .ransack( name_cont: params[:patient][:name], card_number_cont: params[:patient][:identification_number],
                                 prescriptions_type_treatment_eq: params[:patient][:prescription_status],
                                 prescriptions_close_status_eq: params[:patient][:prescription_status].blank? ? nil : 1)
                       .result.distinct
    if paginate == 1
      @patients = @patients.paginate page: params[:page], per_page: Settings.per_page
    end
  end

  def search_not_wait paginate
    if params[:patient][:status].present?
      @patients = Patient.where(issuing_agency_id: @current_user.issuing_agency_id).ransack(
          medicine_allocations_allocation_date_gteq: params[:patient][:allocation_date_from].blank? ? Date.today.to_datetime : params[:patient][:allocation_date_from].to_datetime,
          medicine_allocations_allocation_date_lteq: params[:patient][:allocation_date_to].blank? ? Date.today.end_of_day : params[:patient][:allocation_date_to].to_datetime,
          medicine_allocations_status_eq: params[:patient][:status],
          name_cont: params[:patient][:name],
          card_number_cont: params[:patient][:identification_number],
          prescriptions_type_treatment_eq: params[:patient][:prescription_status],
          prescriptions_close_status_eq: params[:patient][:prescription_status].blank? ? nil : 1).result.distinct
    else
      @patients = Patient.where(issuing_agency_id: @current_user.issuing_agency_id).ransack(
          name_cont: params[:patient][:name],
          card_number_cont: params[:patient][:identification_number],
          prescriptions_type_treatment_eq: params[:patient][:prescription_status],
          prescriptions_close_status_eq: params[:patient][:prescription_status].blank? ? nil : 1).result.distinct
    end

    if paginate == 1
      @patients = @patients.paginate page: params[:page], per_page: Settings.per_page
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
  end

  def delete_patient patient
    if patient.update_attribute :active, 2
      render json: {code: 1, message: "Xóa bệnh nhân thành công"}
    else
      render json: {code: 2, message: "Xóa bệnh nhân thất bại"}
    end
  end

  def type_to_text type
    if type == 1
      return " (sáng)"
    elsif type == 2
      return " (chiều)"
    end
  end

  def check_same_patient action, patient
    @same_patient = nil
    # @patients = Patient.all
    @same_identification_type = false
    # @patients.each do |p|
    #   if(params[:patient][:identification_type] == p.identification_type &&
    #     params[:patient][:identification_number] == p.identification_number)
    #     same_identification_type = true
    #     @same_patient << p
    #   else
    #     if(params[:patient][:name] == p.name &&
    #       params[:patient][:birthdate].to_date == p.birthdate.to_date &&
    #       params[:patient][:province_id] == p.province_id &&
    #       params[:patient][:district_id] == p.district_id &&
    #       params[:patient][:ward_id] == p.ward_id)

    #       @same_patient << p
    #     end
    #   end
    # end
    @same_patient_identification_type = Patient.not_deleted.where(identification_type: Patient.identification_types[params[:patient][:identification_type]])
                                               .where(identification_number: params[:patient][:identification_number])
    @same_patient_name = Patient.not_deleted.where(name: params[:patient][:name])
                                .where("DATE(birthdate) = ?", params[:patient][:birthdate].to_date)
                                .where(province_id: params[:patient][:province_id])
                                .where(district_id: params[:patient][:district_id])
                                .where(ward_id: params[:patient][:ward_id])
    if action == "update"
      @same_patient_identification_type = @same_patient_identification_type.where.not(id: patient.id)
      @same_patient_name = @same_patient_name.where.not(id: patient.id)
    end

    if @same_patient_identification_type.present?
      @same_patient = @same_patient_identification_type
      @same_identification_type = true
    elsif @same_patient_name.present?
      @same_patient = @same_patient_name
    end

    if @same_patient.present?
      @agency = []
      @status = []
      @agency_id = []
      @check_stop_treatment = false
      @check_same_agency = []
      @same_patient.each do |same_patient|
        @agency_id << same_patient.issuing_agency_id
        @agency << same_patient.issuing_agency.name
        check_same_agency = same_patient.issuing_agency.name == @current_user.issuing_agency.name
        @check_same_agency << check_same_agency
        if same_patient.active == "actived"
          @status << "Đang điều trị"
        elsif same_patient.active == "deactived"
          status = "Ngừng điều trị"
          if same_patient.stop_treatment_histories.present?
            status = same_patient.stop_treatment_histories.last.reason rescue nil
          end
          @status << status
          @check_stop_treatment = true
        end
      end
      if @same_identification_type
        @message = "Bệnh nhân vừa tạo đã bị trùng giấy tờ tùy thân"
      else
        @message = "Bệnh nhân vừa tạo đã bị trùng"
      end
      # render json: {code: 3, data: @same_patient,
      #   agency: @agency, status: @status, same_identification_type: same_identification_type,
      #   agency_id:  @agency_id, check_same_agency: @check_same_agency,
      #   current_agency: @current_user.issuing_agency.name, check_stop_treatment: check_stop_treatment,
      #   current_agency_id: @current_user.issuing_agency.id, message: @message}
      render "api/v1/patients/same_patient.json.jbuilder"
    end
    return true if @same_patient.present?
    false
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
