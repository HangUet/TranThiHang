class Api::V1::Admin::SummaryReportsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    date_start = params[:date_start].present? ? params[:date_start].to_date : nil
    date_end = params[:date_end].present? ? params[:date_end].to_date : nil
    @data = total_situation_methadone date_start, date_end, params[:type]

    respond_to do |format|
      format.xlsx do
        if params[:type] == 'situation_methadone'
          send_data export_excel(@data, params[:date_start], params[:date_end])
        elsif params[:type] == 'new_patient_report'
          send_data export_excel_2(@data)
        elsif params[:type] == 'stop_treatment_patient_report'
          send_data export_excel_3(@data)
        end
      end
      format.json
    end
  end

  private

  def total_situation_methadone date_start, date_end, type
    data = []
    if @current_user.role == "admin"
      issuing_agencies = IssuingAgency.select(:id).search(id_eq: params[:issuing_agency_id],
        province_id_eq: params[:province_id], district_id_eq: params[:district_id],
        ward_id_eq: params[:ward_id]).result
      issuing_agencies.each do |issuing_agency|
        if type == 'situation_methadone'
          data << one_situation_methadone(issuing_agency, date_start, date_end)
        elsif type == 'new_patient_report'
          data << new_patient_report(issuing_agency, date_start, date_end)
        elsif type == 'stop_treatment_patient_report'
          data << stop_treatment_patient_report(issuing_agency, date_start, date_end)
        end
      end
    else
      if type == 'situation_methadone'
        data << one_situation_methadone(@current_user.issuing_agency_id, date_start, date_end)
      elsif type == 'new_patient_report'
        data << new_patient_report(@current_user.issuing_agency_id, date_start, date_end)
      elsif type == 'stop_treatment_patient_report'
        data << stop_treatment_patient_report(@current_user.issuing_agency_id, date_start, date_end)
      end

    end
    return data
  end

  def one_situation_methadone issuing_agency_id, date_start, date_end
    issuing_agency = IssuingAgency.find_by id: issuing_agency_id
    if issuing_agency.blank?
      render json: {code: 2, message: "Không tìm thấy đơn vị"}
    end
    date_agency = ""
    tmp_patient_old = Patient.patient_old(issuing_agency_id, date_start, date_end) rescue 0
    total_patient_stop = StopTreatmentHistory.stop_treatment_all(issuing_agency_id, date_start, date_end) rescue 0
    tmp_patient_new = Patient.patient_new(issuing_agency_id, date_start, date_end) rescue 0
    # con phan chuyen co so

    #benh nhan moi chuyen vao co so va thoi gian vao dieu tri nam truoc khoang
    patient_change_agency_before = PatientAgencyHistory.change_agency_before(issuing_agency_id, date_start, date_end)
    #benh nhan moi chuyen vao co so va thoi gian nam trong khoang
    patient_change_agency_in = PatientAgencyHistory.change_agency_in(issuing_agency_id, date_start, date_end)

    #benh nhan dung dieu tri nhung trong khoang thoi gian chua dung

    patient_stop_treatment = Patient.patient_stop_in_time(issuing_agency_id, date_start, date_end)

    #benh nhan chuyen co so sau khoang thoi gian

    patient_change_agency_after = Patient.change_agency_after(issuing_agency_id, date_start, date_end)

    total_patient_old = tmp_patient_old - patient_change_agency_before + patient_stop_treatment + patient_change_agency_after

    total_patient_new = tmp_patient_new + patient_change_agency_before + patient_change_agency_in

    total_patient = total_patient_new + total_patient_old - total_patient_stop


    object = {
      name: issuing_agency.name,
      date_agency: date_agency,
      total_patient_old: total_patient_old,
      total_patient_new: total_patient_new,
      total_patient_stop: total_patient_stop,
      total_patient: total_patient
    }

    return object
  end

  def new_patient_report issuing_agency_id, date_start, date_end
    issuing_agency = IssuingAgency.find_by id: issuing_agency_id
    if issuing_agency.blank?
      render json: {code: 2, message: "Không tìm thấy đơn vị"}
    end

    first_treatment = Patient.being_treated(issuing_agency_id, date_start, date_end).count rescue 0
    change_agency = PatientAgencyHistory.change_agency(issuing_agency_id, date_start, date_end).count rescue 0
    stop_treatment = StopTreatmentHistory.stop_treatment_and_come_back(issuing_agency_id, date_start, date_end) rescue 0

    # first_treatment = tmp - stop_treatment

    total = first_treatment + change_agency + stop_treatment

    object = {
      name: issuing_agency.name,
      first_treatment: first_treatment,
      stop_treatment: stop_treatment,
      change_agency: change_agency,
      total: total
    }

    return object
  end

  def stop_treatment_patient_report issuing_agency_id, date_start, date_end
    issuing_agency = IssuingAgency.find_by id: issuing_agency_id
    if issuing_agency.blank?
      render json: {code: 2, message: "Không tìm thấy đơn vị"}
    end

    arrested_into_center = StopTreatmentHistory.stop_treatment(issuing_agency_id,
      date_start, date_end, "Bị bắt vào trai cai nghiện")


    give_up = StopTreatmentHistory.stop_treatment(issuing_agency_id,
      date_start, date_end, "Tự ý bỏ điều trị") rescue 0

    difference_reason = StopTreatmentHistory.stop_treatment(issuing_agency_id,
      date_start, date_end, "Lý do khác") rescue 0

    died = StopTreatmentHistory.stop_treatment(issuing_agency_id,
      date_start, date_end, "Đã chết") rescue 0

    voluntarily_leaving_program = StopTreatmentHistory.stop_treatment(issuing_agency_id,
      date_start, date_end, "Tự nguyện ra khỏi chương trình") rescue 0

    prisoned = StopTreatmentHistory.stop_treatment(issuing_agency_id,
      date_start, date_end, "Bị bắt tù") rescue 0

    total = arrested_into_center + give_up + difference_reason + died + voluntarily_leaving_program + prisoned

    object = {
      name: issuing_agency.name,
      arrested_into_center: arrested_into_center,
      give_up: give_up,
      difference_reason: difference_reason,
      died: died,
      voluntarily_leaving_program: voluntarily_leaving_program,
      prisoned: prisoned,
      total: total
    }

    return object

  end

  def export_excel data, date_start, date_end
    workbook = RubyXL::Parser.parse("#{Rails.root}/public/template_excel/Bao_cao_tong_hop_1.xlsx")
    worksheet = workbook[0]

    # worksheet.add_cell(0, 0, "Tình hình điều trị đến #{date_end}")

    # worksheet.insert_row(3)
    # worksheet.add_cell(3, 0, "")
    # worksheet.add_cell(3, 1, "")
    # worksheet.add_cell(3, 2, "")
    # worksheet.add_cell(3, 3, "")
    # worksheet.add_cell(3, 4, "đến #{date_end}")
    # worksheet.add_cell(3, 5, "từ #{date_start} đến #{date_end}")
    # worksheet.add_cell(3, 6, "từ #{date_start} đến #{date_end}")
    # worksheet.add_cell(3, 7, "đến #{date_end}")
    data.each_with_index do |row, index|
      index_row = index + 4
      worksheet.insert_row(index_row)

      worksheet.add_cell(index_row, 0, "#{index + 1}")
      worksheet.add_cell(index_row, 1, "#{row[:name]}")
      worksheet.add_cell(index_row, 2, "#{row[:date_agency]}")
      worksheet.add_cell(index_row, 3, "")
      worksheet.add_cell(index_row, 4, "#{row[:total_patient_old]}")
      worksheet.add_cell(index_row, 5, "#{row[:total_patient_new]}")
      worksheet.add_cell(index_row, 6, "#{row[:total_patient_stop]}")
      worksheet.add_cell(index_row, 7, "#{row[:total_patient]}")
    end

    workbook.stream.string
  end

  def export_excel_2 data
    workbook = RubyXL::Parser.parse("#{Rails.root}/public/template_excel/Bao_cao_tong_hop_2.xlsx")
    worksheet = workbook[0]

    data.each_with_index do |row, index|
      index_row = index + 2
      worksheet.insert_row(index_row)
      worksheet.add_cell(index_row, 0, "#{index + 1}")
      worksheet.add_cell(index_row, 1, "#{row[:name]}")
      worksheet.add_cell(index_row, 2, "#{row[:first_treatment]}")
      worksheet.add_cell(index_row, 3, "#{row[:stop_treatment]}")
      worksheet.add_cell(index_row, 4, "#{row[:change_agency]}")
      worksheet.add_cell(index_row, 5, "#{row[:total]}")
    end

    workbook.stream.string
  end

   def export_excel_3 data
    workbook = RubyXL::Parser.parse("#{Rails.root}/public/template_excel/Bao_cao_tong_hop_3.xlsx")
    worksheet = workbook[0]

    data.each_with_index do |row, index|
      index_row = index + 2
      worksheet.insert_row(index_row)
      worksheet.add_cell(index_row, 0, "#{index + 1}")
      worksheet.add_cell(index_row, 1, "#{row[:name]}")
      worksheet.add_cell(index_row, 2, "#{row[:voluntarily_leaving_program]}")
      worksheet.add_cell(index_row, 3, "#{row[:died]}")
      worksheet.add_cell(index_row, 4, "#{row[:prisoned]}")
      worksheet.add_cell(index_row, 5, "#{row[:arrested_into_center]}")
      worksheet.add_cell(index_row, 6, "#{row[:difference_reason]}")
      worksheet.add_cell(index_row, 7, "#{row[:give_up]}")
      worksheet.add_cell(index_row, 8, "#{row[:total]}")
    end

    workbook.stream.string
  end
end
