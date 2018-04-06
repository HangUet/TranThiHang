class Api::V1::MedicineAllocationsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    if (params[:patient_id] && params[:from_date] && params[:to_date])
      @history_medicine_allocation = MedicineAllocation.taked.history_allocation_patient(params[:from_date], params[:to_date], params[:patient_id])
    else
      check_warning params[:patient_id]
      today  = Date.today
      hours = Time.now.hour
      type = hours < 12 ? [1, 3] : [2, 3]
      @allow_allocation = nil
      @prescriptions = Prescription.open.where(patient_id: params[:patient_id])
                                       .where("DATE(begin_date) <= ? and prescription_type != 'temp_afternoon'
                                        and prescription_type != 'temp_morning' and prescription_type != 'temp_day'", today)
                                       .where("DATE(end_date) >= ?", today).order(id: :desc)
      if @prescriptions.present?
        if @prescriptions.size > 1
          @prescriptions[1..-1].each do |prescription|
            prescription.update_attributes close_status: 2, end_date: today
          end
        end
        @prescription = @prescriptions.first
      end
      if @prescription.present?
        @allow_allocation = 1
        check_vommited
        if @check_vommited.present?
          @medical_allocations = []
          @waiting_doctor = 1
          notify_status = [0, 2]
          if @prescription.dosage_morning == 0 || @prescription.dosage_morning.nil?
            @medical_allocations << @check_vommited
          else
            vomited_morning = MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:vomited])
              .where("patient_id = ? and DATE(allocation_date) = ? and vomited_allocation = 0 and typee = 1", params[:patient_id], Date.today).last
            vomited_afternoon = MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:vomited])
              .where("patient_id = ? and DATE(allocation_date) = ? and vomited_allocation = 0 and typee = 2", params[:patient_id], Date.today).last

            #non buoi sang
            if vomited_morning.present? && vomited_afternoon.blank?
              @medical_allocations << vomited_morning
              @medical_allocations <<  MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:not_fall])
                .where("patient_id = ? and DATE(allocation_date) = ? and typee = 2", params[:patient_id], Date.today).last
            #non buoi chieu
            elsif vomited_morning.blank? && vomited_afternoon.present?
              @medical_allocations <<MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:not_fall])
                .where("patient_id = ? and DATE(allocation_date) = ? and typee = 1", params[:patient_id], Date.today).last
              @medical_allocations <<  vomited_afternoon
            #non ca sang, ca chieu
            else
              @medical_allocations << vomited_morning
              @medical_allocations << vomited_afternoon
            end
          end
          # @medical_allocations = MedicineAllocation.where(notify_status: notify_status)
          #   .where("patient_id = ? and DATE(allocation_date) = ?", params[:patient_id], Date.today).order(:typee)
        else
          prescriptions = []
          #lieu dung ca ngay
          if @prescription.dosage_morning == 0 || @prescription.dosage_morning.nil?
            #check don non ca ngay
            prescription_vomited_day = Prescription.where(patient_id: params[:patient_id])
                                         .where("DATE(begin_date) <= ? and prescription_type = 'temp_day' and show_status = 0", today)
                                         .where("DATE(end_date) >= ?", today)
                                         .select(:id).last

            if prescription_vomited_day.present?
              prescriptions << prescription_vomited_day.id
            else
              prescriptions << @prescription.id
            end

          else
            #lieu dung sang chieu
            prescription_vomited_afternoon = Prescription.where(patient_id: params[:patient_id])
                                         .where("DATE(begin_date) <= ? and prescription_type = 'temp_afternoon' and show_status = 0", today)
                                         .where("DATE(end_date) >= ?", today)
                                         .select(:id).last
            prescription_vomited_morning = Prescription.where(patient_id: params[:patient_id])
                                         .where("DATE(begin_date) <= ? and prescription_type = 'temp_morning' and show_status = 0", today)
                                         .where("DATE(end_date) >= ?", today)
                                         .select(:id).last
            #mang id don thuoc
            if prescription_vomited_afternoon.present?
              prescriptions << prescription_vomited_afternoon.id
            end

            if prescription_vomited_morning.present?
              prescriptions << prescription_vomited_morning.id
            end

            if prescriptions.length < 2
              prescriptions << @prescription.id
            end
          end

          check_medicine_alloctaion_exist prescriptions

          unless @medical_allocations.present?
            if @prescription.dosage_morning.nil? || @prescription.dosage_morning == 0
              dosage = @prescription.dosage
              typee = "day"
              create_medicine_allocation dosage, typee, @prescription.id
              @medical_allocations << @medical_allocation
            else
              dosage_morning = @prescription.dosage_morning
              typee_morning = "morning"

              dosage_afternoon = @prescription.dosage.to_f - @prescription.dosage_morning.to_f
              typee_afternoon = "afternoon"

              create_medicine_allocation dosage_morning, typee_morning, @prescription.id
              @medical_allocations << @medical_allocation
              create_medicine_allocation dosage_afternoon, typee_afternoon, @prescription.id
              @medical_allocations << @medical_allocation
            end
          end
        end
        medicine_list_id = @prescription.medicine_list_id

        medicine_list_group = MedicineList.find_by(id: @prescription.medicine_list_id)
          .medicine_type_id

        medicine_list_ids = MedicineList.where(medicine_type_id: medicine_list_group)
          .pluck(:id)

        # thuốc trả về
        @day_medicines = Medicine.allocation.where(issuing_agency_id: current_user.issuing_agency_id)
                                            .where(medicine_list_id: medicine_list_ids)
                                            .where("DATE(init_date) = ?", Date.today)

      end
    end

    if @warning
      if @warning[:level] == "obligatory"
        @allow_allocation = 0
      elsif @warning[:level] == "optional"
        @allow_allocation = 1
      end
    end
  end

  def create

    allocation_status_param = params[:allocation][:status]
    check_warning params[:patient_id]
    if @warning.nil? || @warning && !(@warning[:level] == "obligatory")
      @medical_allocation = MedicineAllocation.find_by_id(params[:medicine_allocation_id])
      medicine = Medicine.where(id: params[:drinked_day_medicine_id]).first
      concentration = medicine.medicine_list.concentration
      if allocation_status_param == "allocated" && !params[:back] && @medical_allocation.status == "waiting"
        if params[:drinked_day_medicine_id] == nil
          render json: {code: 2, message: "Không tìm thấy lô."}
          return
        end
        if medicine.present?
          @medicine_patch = medicine.production_batch
        end
        # cộng thêm booking của medicine và update lô
        medicine.update_attributes booking: medicine.booking + @medical_allocation.dosage/concentration
        @medical_allocation.update_attributes(medicine_id: medicine.id)


      elsif allocation_status_param == "allocated" && params[:back] && @medical_allocation.status == "taked"
        inventory = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                            .where("DATE(datee) = ?", Date.today)
                            .where(medicine_id: medicine.origin_medicine_id).first
        if inventory.present?
          inventory.update_attributes allocate: inventory.allocate - @medical_allocation.dosage/concentration,
                                      export: inventory.export - @medical_allocation.dosage/concentration
        else
          render json: {code: 2, message: "Không thể trừ tồn kho"}
          return
        end
      elsif allocation_status_param == "waiting" && @medical_allocation.status == "allocated"
        @medical_allocation.update_attributes(medicine_id: nil)

        # trừ đi booking medicine
        medicine.update_attributes booking: medicine.booking - @medical_allocation.dosage/concentration
      end

      if params[:allocation][:status] == "taked" && @medical_allocation.status == "allocated"
        prescription = @medical_allocation.prescription
        if prescription.prescription_type == 'temp_day' || prescription.prescription_type == 'temp_morning' ||
          prescription.prescription_type == 'temp_afternoon'
          prescription.update_attributes close_status: 2
        end
        inventory = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                              .where("DATE(datee) = ?", Date.today)
                              .where(medicine_id: medicine.origin_medicine_id).first
        if inventory.present?
          inventory.update_attributes allocate: inventory.allocate + @medical_allocation.dosage/concentration,
                                      export: inventory.export + @medical_allocation.dosage/concentration
        else
          endd = 0
          last_inventory = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
            .where("datee < ?", Date.today).order(datee: :desc).first
          if last_inventory.present?
            endd = last_inventory.endd
          end
          Inventory.create datee: Time.now, beginn: endd, allocate: @medical_allocation.dosage/concentration,
                            issuing_agency_id: current_user.issuing_agency_id, medicine_id: medicine.origin_medicine_id,
                            endd: endd, export: @medical_allocation.dosage/concentration
        end
      end

      if @medical_allocation && @medical_allocation.not_fall?
        @medical_allocation.update dosage: params[:allocation][:dosage], user_id: @current_user.id,
          status: params[:allocation][:status]
        render json: {code: 1, message: t("common.success"), data: @medical_allocation}
      end
    else
      render json: {code: 0, message: "error" }
    end
  end

  def update
    if (params[:status] == "accept")
      notify_status = params[:notify_status]
    else
      notify_status = "not_fall"
    end
    @medical_allocation = MedicineAllocation.create patient_id: medical_allocation.patient_id,
      allocation_date: Time.now, user_id: @current_user.id, dosage: medical_allocation.dosage,
      status: "waiting"
    if medical_allocation.update_attributes(notify_status: notify_status)
      render json: {code: 1, message: t("notification.update.success")}
    else
      render json: {code: 2, message: t("notification.update.success")}
    end
  end

  def destroy
    @medicine_allocation = MedicineAllocation.find_by_id(params[:id])
    medicine_id = @medicine_allocation.medicine.origin_medicine_id
    concentration = Medicine.find_by(id: medicine_id).medicine_list.concentration
    if @medicine_allocation.notify_status == "falled"
      if @medicine_allocation.update_attributes(active: "deactived")
        update_inventory "not_fall", @medicine_allocation.allocation_date.to_date.strftime,
          current_user.issuing_agency_id, @medicine_allocation.dosage/concentration, medicine_id
        render json: {code: 1, message: "Xóa thành công"}
      else
        render json: {code: 2, message: "Thao tác thất bại"}
      end
    end
  end

  def get_dosage_patient
    if params[:date]
      @month = params[:date].split("/")[0]
      @year = params[:date].split("/")[1]
      @medical_allocations = MedicineAllocation.allocation_patient(@month, @year, params[:patient_id])
    else
      @medical_allocations = MedicineAllocation.allocation_patient(Time.now.month, Time.now.year, params[:patient_id])
    end
    @results = Array.new(Time.now.end_of_month.day + 1, "-")
    @medical_allocations.each do |medical_allocation|
      @results[medical_allocation.day] = medical_allocation.dosage
    end
  end

  def get_by_patient
    @patients_allocation = Patient.not_deleted.where(issuing_agency_id: @current_user.issuing_agency_id).paginate page: params[:page], per_page: Settings.per_page
    @totals = Array.new(Time.now.end_of_month.day, 0)
    @result = Patient.not_deleted.get_allocation_day(@current_user.issuing_agency_id)
    @result.each do |s|
      @totals[s.day - 1] = s.sum
    end
  end

  def get_patient_report
    if params[:month]
      month = params[:month].split("/")[0]
      year = params[:month].split("/")[1]
    else
      month = Time.now.month
      year = Time.now.year
    end

    @issuing_agency_id = @current_user.issuing_agency_id
    @issuing_agency_name = @current_user.issuing_agency.name

    @patient_give_up = Patient.not_deleted.joins(:medicine_allocations)
      .where("issuing_agency_id = ? and status = 0 and
      MONTH(allocation_date) = ?
      and YEAR(allocation_date) = ?", @issuing_agency_id, month, year)
    @male_give_up = @patient_give_up.where("gender = 'male'").distinct.count
    @female_give_up = @patient_give_up.where("gender = 'female'").distinct.count
    @male_turn_give_up = @patient_give_up.where("gender = 'male'").count
    @female_turn_give_up = @patient_give_up.where("gender = 'female'").count
  end

  def get_by_id
    @medical_allocation = MedicineAllocation.find_by_id(params[:id])
    if @medical_allocation
      render json: {code: 1, message: t("common.success"), data: @medical_allocation}
    else
      render json: {code: 1, message: "error", data: @medical_allocation}
    end
  end

  def get_history_falled
    if params[:status].present?
      params[:status] = params[:status].to_i
    end
    if params[:page].blank?
      params[:page] = 1
    end
    if params[:card_number].present?
      params[:card_number] = "%" + params[:card_number] + "%"
    end
    if params[:name].present?
      params[:name] = "%" + params[:name] + "%"
    end
    if params[:from_date].present? && params[:to_date].blank?
      @history_falled = MedicineAllocation.falled.joins(:user)
        .joins(:patient).select('medicine_allocations.*').select(:name, :card_number, :first_name, :last_name)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("DATE(allocation_date) >= ?", params[:from_date].to_date)
        .where("(:creator = '' or  :creator is NULL or users.id = :creator) and
                (:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number) and
                (:status is NULL or medicine_allocations.active = :status)",
              {
                creator: params[:creator],
                name: params[:name],
                card_number: params[:card_number],
                status: params[:status],
              })
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:from_date].blank? && params[:to_date].present?
      @history_falled = MedicineAllocation.falled.joins(:user)
        .joins(:patient).select('medicine_allocations.*').select(:name, :card_number, :first_name, :last_name)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("DATE(allocation_date) <= ?", params[:to_date].to_date)
        .where("(:creator = '' or  :creator is NULL or users.id = :creator) and
                (:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number) and
                (:status is NULL or medicine_allocations.active = :status)",
              {
                creator: params[:creator],
                name: params[:name],
                card_number: params[:card_number],
                status: params[:status],
              })
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:from_date].present? && params[:to_date].present?
      @history_falled = MedicineAllocation.falled.joins(:user)
        .joins(:patient).select('medicine_allocations.*').select(:name, :card_number, :first_name, :last_name)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("DATE(allocation_date) <= ? and DATE(allocation_date) >= ?", params[:to_date].to_date, params[:from_date].to_date)
        .where("(:creator = '' or  :creator is NULL or users.id = :creator) and
                (:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number) and
                (:status is NULL or medicine_allocations.active = :status)",
              {
                creator: params[:creator],
                name: params[:name],
                card_number: params[:card_number],
                status: params[:status],
              })
        .paginate page: params[:page], per_page: Settings.per_page
    elsif params[:from_date].blank? && params[:to_date].blank?
      @history_falled = MedicineAllocation.falled.joins(:user)
        .joins(:patient)
        .where("users.issuing_agency_id = ?", @current_user.issuing_agency_id)
        .where("(:creator = '' or  :creator is NULL or users.id = :creator) and
                (:name = '' or :name is NULL or patients.name like :name) and
                (:card_number = '' or :card_number is NULL or patients.card_number like :card_number) and
                (:status is NULL or medicine_allocations.active = :status)",
              {
                creator: params[:creator],
                name: params[:name],
                card_number: params[:card_number],
                status: params[:status],
              })
        .where("DATE(allocation_date) = ?", Date.today)
        .select('medicine_allocations.*').select(:name, :card_number, :first_name, :last_name)
        .paginate page: params[:page], per_page: Settings.per_page
    end
    render json: {code: 1, message: "success", data: @history_falled, total: @history_falled.total_entries,
      per_page: Settings.per_page, page: params[:page]}
  end

  private

  def check_warning patient_id

    today  = Date.today
    @allow_allocation = nil
    @prescription = Prescription.open.where(patient_id: params[:patient_id])
    if @prescription.present?
      @prescription = @prescription.where("DATE(begin_date) <= ?", today)
                                   .where('DATE(end_date) >= ?', today).first
      if !@prescription.present?
        @warning = {content: Settings.patient_warning.content.obligatory, level: "obligatory", status: "open"}
      else
        if @prescription.end_date.day == (today + 1.days).day || @prescription.end_date.day == today.day
          @warning = {content: Settings.patient_warning.content.optional, level: "optional", status: "open"}
        end
      end
    else
      @warning = {content: Settings.patient_warning.content.optional, level: "empty_prescription", status: "open"}
    end

    # @warning = PatientWarning.where(status: 1, patient_id: patient_id).last
  end

  def create_medicine_allocation dosage, typee, prescription_id
    @medical_allocation = MedicineAllocation.create(patient_id: params[:patient_id],
      allocation_date: Time.now, user_id: @current_user.id, dosage: dosage,
      status: "waiting", typee: typee, prescription_id: prescription_id)
  end

  def check_vommited
    @check_vommited = MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:vomited])
      .where("patient_id = ? and DATE(allocation_date) = ? and vomited_allocation = 0", params[:patient_id], Date.today).last
  end

  def check_medicine_alloctaion_exist prescription_id
    @medical_allocations = MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:not_fall])
      .where("patient_id = ? and DATE(allocation_date) = ?", params[:patient_id], Date.today).where(prescription_id: prescription_id).order(:typee)
  end
end
