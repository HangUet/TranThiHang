class Api::V1::IssuingAgenciesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @issuing_agencies = IssuingAgency.all
      .search(name_or_code_cont: params[:keyword]).result
      .order(id: :desc)
      .paginate page: params[:page], per_page: Settings.per_page
  end
  def get_by_province
    @issuing_agencies = IssuingAgency.select(:id, :name).where(province_id: params[:province_id])
                        .where("name != ?", @current_user.issuing_agency.name)
    render json: {data: @issuing_agencies, code: 1, message: t("common.success")}
  end
end
