class Api::V1::EthnicitiesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    ethnicities = Ethnicity.all.select(:id, :name).order(:name)
    render json: {data: ethnicities, code: 1, message: t("common.success")}
  end

  def show
    ethnicity = Ethnicity.find_by id: params[:id]
    render json: {data: ethnicity, code: 1, message: t("common.success")}
  end
end
