class Api::V1::PrescriptionsController < ApplicationController
  before_action :authenticate_request!
  before_action :check_conflict_prescription, only: :index
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    patient_id = params[:patient_id]
    current_user_id = @current_user.id
    @prescriptions = Prescription.where(patient_id: patient_id).order(end_date: :desc)
    prescription_open = Prescription.open.where("DATE(end_date) < ?", Date.today)
    prescription_open.update_all(close_status: 2)
    render json: {code: 1, data: Prescription.format_data(@prescriptions, current_user_id), message: ""}
  end

  def show
    @prescription = Prescription.where(patient_id: params[:id]).last
    date_now = Time.now.strftime "%d/%m/%Y"
    render json: {code: 1, data: @prescription, date: date_now}
  end

  def filter_prescription
    @prescription = Prescription.where(patient_id: params[:patient_id])
      .ransack(begin_date_gteq: params[:begin_date_from].to_datetime,
          begin_date_lteq: (params[:begin_date_to].to_date.end_of_day rescue nil),
          end_date_gteq: params[:end_date_from].to_datetime,
          end_date_lteq: (params[:end_date_to].to_date.end_of_day rescue nil),
          user_id_eq: params[:doctor_id]).result.order(end_date: :desc)
    render json: {code: 1, data: Prescription.format_data(@prescription, @current_user.id)}
  end

  def getPrescription
    @prescription = Prescription.find_by id: params[:id]
    unless @prescription.present?
      render json: {code: 2, data: nil}
    end
  end

  def get_last_prescription_of_patient
    @prescription = Prescription.where(patient_id: params[:patient_id])
      .where("DATE(begin_date) <= ? and prescription_type != 'temp_afternoon' and prescription_type != 'temp_morning' and prescription_type != 'temp_day'", Date.today).last
    render json: {code: 1, data: @prescription}
  end

  def closePrescription
    prescription = Prescription.find_by id: params[:id]
    if prescription.update_attributes(end_date: Time.now, close_status: "close")
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Cập nhật thất bại"}
    end
  end

  def check_vomited
    vomited_prescription = Prescription.open.where("prescription_type = 'temp_afternoon' 
      or prescription_type = 'temp_morning' or prescription_type = 'temp_day'")
      .where(patient_id: params[:prescription][:patient_id])

    vomited = MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:vomited])
      .where("patient_id = ? and DATE(allocation_date) = ? and vomited_allocation = 0", params[:prescription][:patient_id], Date.today).last
    if vomited_prescription.present?
      render json: {code: 2, message: "Bệnh nhân chưa uống đơn bổ sung sau nôn, không được kê đơn mới!"}
      return
    elsif vomited.present?
      render json: {code: 2, message: "Bệnh nhân đang bị nôn, vui lòng kiểm tra phần thông báo!"}
      return
    else
      render json: {code: 1}
    end
  end

  def create
    if prescription_params[:begin_date].to_date < Date.today
      render json: {code: 2, message: "Ngày bắt đầu nhỏ hơn ngày hiện tại"}
      return
    end

    vomited_prescription = Prescription.open.where("prescription_type = 'temp_afternoon' 
      or prescription_type = 'temp_morning' or prescription_type = 'temp_day'")
      .where(patient_id: params[:prescription][:patient_id])

    if vomited_prescription.present?
      render json: {code: 3, message: "Bệnh nhân chưa uống đơn bổ sung sau nôn"}
      return
    end
    patient = Patient.find_by_id (params[:prescription][:patient_id])
    check_today_allocation = patient.medicine_allocations.where("status = ? or status = ?", 1, 2).where("DATE(allocation_date) = ?", Date.today)
    if params[:prescription][:check_today_allocation].blank? && prescription_params[:begin_date].to_date == Date.today &&
      check_today_allocation.present? && params[:status] != "agree_prescription"
      render json: {code: 3, message: "Bệnh nhân đã được cấp phát thuốc trong ngày hôm nay, bạn có muốn tiếp tục thêm đơn thuốc ?"}
      return
    end
    if patient.deactived?
      render json: {code: 2, message: "Bệnh nhân đã dừng điều trị"}
      return
    end
    if (patient.admission_date.to_date rescue nil)
      if prescription_params[:begin_date].to_date < patient.admission_date.to_date
        render json: {code: 2, message: "Ngày bắt đầu không đưọc nhỏ hơn ngày vào điều trị"}
        return
      end
    end
    if params[:status] == "agree_prescription"
      medical_allocation_now = MedicineAllocation.find_by_id(params[:medicine_allocation_id])
      medical_allocation_now.update_attributes(vomited_allocation: :confirmed)
      prescription_now = Prescription.find_by_id(params[:prescription_id])

      if params[:vomited_time] == "day"
        type = "temp_day"
      elsif params[:vomited_time] == "morning"
        type = "temp_morning"
      elsif params[:vomited_time] == "afternoon"
        type = "temp_afternoon"
      end

      prescription = Prescription.new prescription_params.merge(user_id: @current_user.id,
        end_date: prescription_params[:end_date_expected], close_status: "open",
        prescription_type: type, dosage_morning: nil,
        description: prescription_now.description,
        medicine_list_id: prescription_now.medicine_list.id,
        show_status: "show")

      if prescription.save
        MedicineAllocation.create patient_id: params[:prescription][:patient_id],
          allocation_date: Time.now, user_id: @current_user.id,
          dosage: params[:prescription][:dosage], status: "waiting",
          typee: medical_allocation_now.typee, prescription_id: prescription.id
        render json: {code: 1, message: "Cập nhật thành công"}
      else
        render json: {code: 2, message: "Cập nhật thất bại"}
      end
    else
      check_stop_treament = Patient.find_by_id(prescription_params[:patient_id]).actived? rescue nil
      if check_stop_treament
        medicine_list = MedicineList.where(id: params[:prescription][:medicine_list_id][:id]).first
        unless medicine_list.present?
          render json: {code: 2, message: "Thuốc không đúng"}
          return
        end
        prescription = Prescription.new prescription_params.merge(user_id: @current_user.id,
          end_date: prescription_params[:end_date_expected],
          close_status: "open", medication_name: params[:prescription][:medication_name],
          medicine_list_id: medicine_list.id)
        # check_date_range_conflict_end = Prescription.open.where(patient_id: prescription_params[:patient_id])
        #   .where("DATE(end_date_expected) >= ? and DATE(end_date_expected) <= ?",
        #     prescription.begin_date.to_date,
        #     prescription.end_date_expected.to_date)
        # check_date_range_conflict_begin = Prescription.open.where(patient_id: prescription_params[:patient_id])
        #   .where("DATE(begin_date) >= ? and DATE(begin_date) <= ?", prescription.begin_date.to_date,
        #     prescription.end_date_expected.to_date)

        # if check_date_range_conflict_begin.present?
        #   render json: {code: 1, message: "Khoảng thời gian của đơn thuốc bị trùng với đơn thuốc khác."}
        #   # check_date_range_conflict_begin.update_all(close_status: 2, end_date: Time.now)
        # end
        # if check_date_range_conflict_end.present?
        #   render json: {code: 1, message: "Khoảng thời gian của đơn thuốc bị trùng với đơn thuốc khác."}
        #   # check_date_range_conflict_end.update_all(close_status: 2, end_date: Time.now)
        # end

        check_future_prescription = Prescription.open.where(patient_id: prescription_params[:patient_id])
          .where("DATE(begin_date) > ?", Date.today)
        if check_future_prescription.present?
          if check_future_prescription.size >= 1
            render json: {code: 2, message: "Đơn thuốc chỉ được phép tạo một đơn trong tương lai."}
            return
          end
        end

        delete_medicine_allocation prescription.patient_id

        if prescription.save

          vomited_prescription = Prescription.where("prescription_type = 'temp_afternoon' 
            or prescription_type = 'temp_morning' or prescription_type = 'temp_day'")
            .where(patient_id: params[:prescription][:patient_id])

          vomited_prescription.update_all(show_status: 1)

          render json: {code: 1, message: "Tạo đơn thuốc thành công"}
        else
          render json: {code: 2, message: prescription.errors.full_messages[0]}
        end
      else
        render json: {code: 2, message: "Bệnh nhân đã dừng điều trị"}
      end
    end
  end

  def update
    patient = Patient.find_by_id (params[:prescription][:patient_id])
    if prescription_params[:begin_date].to_date < Date.today
      render json: {code: 2, message: "Ngày bắt đầu không hợp lệ"}
      return
    end
    if (patient.admission_date.to_date rescue nil)
      if prescription_params[:begin_date].to_date < patient.admission_date.to_date
        render json: {code: 2, message: "Ngày bắt đầu không đưọc nhỏ hơn ngày vào điều trị"}
        return
      end
    end
    if params[:prescription][:user_id] != @current_user.id
      render json: {code: 2, message: "Chỉ người tạo đơn mới sửa được đơn"}
      return
    end
    if patient.deactived?
      render json: {code: 2, message: "Bệnh nhân đã dừng điều trị"}
      return
    end
    prescription = Prescription.find_by id: params[:id]
    patient = Patient.find_by_id (params[:prescription][:patient_id])
    check_today_allocation = patient.medicine_allocations.where(prescription_id: prescription.id).where("status = ? or status = ?", 1, 2).where("DATE(allocation_date) = ?", Date.today)
    if prescription_params[:begin_date].to_date == Date.today && check_today_allocation.present?
      render json: {code: 2, message: "Bệnh nhân đã được cấp phát thuốc, không sửa đơn!"}
      return
    end
    if(prescription_params[:begin_date].to_date <= Date.today &&
      prescription_params[:end_date_expected].to_date >= Date.today &&
      check_today_allocation.present?)
      render json: {code: 2, message: "Bệnh nhân đã được cấp phát thuốc trong ngày hôm nay"}
      return
    end
    # medicine_allocations = patient.medicine_allocations.where("status = 0")
    #   .where("DATE(allocation_date) = ?", Date.today).destroy_all
    prescription.assign_attributes(prescription_params)
    medicine_list = MedicineList.where(id: params[:prescription][:medicine_list_id][:id]).first
    unless medicine_list.present?
      render json: {code: 2, message: "Thuốc không đúng"}
      return
    end
    prescription.assign_attributes(end_date: prescription_params[:end_date_expected],
      medication_name: params[:prescription][:medication_name], medicine_list_id: medicine_list.id)

    # check_date_range_conflict = Prescription.open.where(patient_id: prescription.patient_id)
    #   .where("begin_date <= ? AND end_date_expected >= ? AND id != ?", prescription.end_date_expected, prescription.begin_date, params[:id])
    #   .exists?

    # if check_date_range_conflict
    #   render json: {code: 2, message: "Khoảng thời gian của đơn thuốc bị trùng với đơn thuốc khác."}
    #   return
    # end

    if prescription.prescription_type == 'temp_morning' || prescription.prescription_type == 'temp_afternoon' || prescription.prescription_type == 'temp_day'
      # thay doi lieu luong don non
      medication_allocations_vomited = MedicineAllocation.where(prescription_id: prescription.id)
      medication_allocations_vomited.update_all dosage: params[:prescription][:dosage]
    else
      delete_medicine_allocation prescription.patient_id
    end
    if prescription.save
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Cập nhật thất bại"}
    end
  end

  def destroy
    prescription = Prescription.find_by id: params[:id]
    patient = prescription.patient
    check_today_allocation = patient.medicine_allocations.where(prescription_id: prescription.id).where("status = ? or status = ?", 1, 2).where("DATE(allocation_date) = ?", Date.today)
    if(prescription.begin_date.to_date <= Date.today &&
      prescription.end_date_expected.to_date >= Date.today &&
      check_today_allocation.present?)
      render json: {code: 2, message: "Bệnh nhân đã được cấp phát thuốc trong ngày hôm nay"}
      return
    end
    if patient.deactived?
      render json: {code: 2, message: "Bệnh nhân đã dừng điều trị"}
      return
    end
    if prescription.medicine_allocations.allocated.present?
      render json: {code: 2, message: "Không thể xóa đơn thuốc đã đưọc cấp phát"}
      return
    end
    medicine_allocations = MedicineAllocation.where(prescription_id: prescription.id)
    medicine_allocations.delete_all
    if prescription.destroy
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def prescription_params
    params[:prescription][:dosage_morning] = 0 unless params[:prescription][:dosage_morning]
    params.require(:prescription).permit :dosage, :begin_date, :end_date_expected,
      :prescription_type, :patient_id, :description, :dosage_morning, :type_treatment
  end

  def delete_medicine_allocation patient_id
    MedicineAllocation.where(notify_status: MedicineAllocation.notify_statuses[:not_fall])
      .where("patient_id = ? and DATE(allocation_date) = ? and status = ?",
      prescription_params[:patient_id], Date.today, MedicineAllocation.statuses[:waiting]).delete_all
  end

  # neu hom nay co don thuoc , dong don thuoc cu
  def check_conflict_prescription
    today = Date.today
    @prescriptions_today = Prescription.open.where("prescription_type != 'temp_afternoon' and prescription_type != 'temp_morning' and prescription_type != 'temp_day'")
                                      .where(patient_id: params[:patient_id])
                                      .where("DATE(begin_date) <= ?", today)
                                      .where("DATE(end_date) >= ?", today).order(id: :desc)
    if @prescriptions_today.present?
      if @prescriptions_today.size > 1
        @prescriptions_today[1..-1].each do |prescription|
          prescription.update_attributes close_status: 2, end_date: today
        end
      end
    end
  end
end
