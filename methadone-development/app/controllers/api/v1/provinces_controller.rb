class Api::V1::ProvincesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    provinces = Province.all.select(:id, :name).order(:name)
    render json: {data: provinces, code: 1, message: t("common.success")}
  end
end
