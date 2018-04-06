class Api::V1::Admin::IssuingAgenciesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @issuing_agencies = IssuingAgency.all.select(:id, :name).order(:name)
    render json: {code: 1, message: "", data: @issuing_agencies}
  end

  def option_report
    @issuing_agencies = IssuingAgency
      .select(:id, :name, :province_id, :district_id, :ward_id)
      .search(province_id_eq: params[:province_id],
              district_id_eq: params[:district_id],
              ward_id_eq: params[:ward_id]).result
    render json: {code: 1, message: "", data: @issuing_agencies}
  end

  def show
    @issuing_agency = IssuingAgency.find_by id: params[:id]
    render json: {code: 1, data: @issuing_agency}
  end

  def create
    issuing_agencies_count = IssuingAgency.all.size + 1

    return render json: {code: 2, message: "Please select province"} unless params[:issuing_agency][:province_id]
    return render json: {code: 2, message: "Please select district"} unless params[:issuing_agency][:district_id]
    return render json: {code: 2, message: "Please select ward"} unless params[:issuing_agency][:ward_id]

    province = Province.find_by(id: issuing_agency_params[:province_id])
    code = province.code +
       "0"*(2 - issuing_agencies_count.to_s.length) +
       issuing_agencies_count.to_s rescue ""
    issuing_agency = IssuingAgency.new issuing_agency_params.merge(code: code)
    if issuing_agency.save
      PatientSequence.create issuing_agency_id: issuing_agency.id
      render json: {code: 1, message: t("issuing_agency.create.success")}
    else
      render json: {code: 2, message: t("issuing_agency.create.fails")}
    end
  end

  def update
    issuing_agency = IssuingAgency.find_by id: params[:id]
    if issuing_agency.update_attributes(issuing_agency_params)
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Cập nhật thất bại"}
    end
  end

  def destroy
    issuing_agency = IssuingAgency.find_by id: params[:id]
    if issuing_agency.destroy
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: issuing_agency.errors[:base][0]}
    end
  end

  private

  def issuing_agency_params
    params.require(:issuing_agency).permit :name, :address, :province_id , :district_id, :ward_id
  end
end
