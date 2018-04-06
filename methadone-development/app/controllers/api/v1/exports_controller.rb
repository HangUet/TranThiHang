class Api::V1::ExportsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def index
    @patient = Patient.not_deleted.find_by id: params[:patient_id]
    @prescription = Prescription.where(patient_id: params[:patient_id]).last
    @address =  getString(@patient.address).to_s + getString(@patient.hamlet).to_s + getString(@patient.ward.name).to_s + getString(@patient.district.name).to_s + endString(@patient.province.name).to_s
    @medicine_allocations = MedicineAllocation.select(:allocation_date, :dosage).where("patient_id = ? AND YEAR(allocation_date) = ? AND MONTH(allocation_date) = ? and status = 2", params[:patient_id], params[:year], params[:month])
    if @patient.avatar
      @url_image = Rails.root+"public#{@patient.avatar}"
    else
      @url_image = Rails.root+'public/images/avatar.jpg'
    end

    unless File.exists? File.expand_path(@url_image)
      @url_image = Rails.root+'public/images/avatar.jpg'
    end

    respond_to do |format|
      format.xlsx
    end
  end


  private

  def getString string
    if string.present?
      return string.to_s + " - ";
    end

    return ""
  end

  def endString string
    if string.present?
      return string.to_s;
    end

    return ""
  end

end
