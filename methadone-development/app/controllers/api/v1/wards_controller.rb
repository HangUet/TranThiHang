class Api::V1::WardsController < ApplicationController
	before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    wards = Ward.select(:id, :name)
                        .where(district_id: params[:district_id])
                        .order(:name)
    render json: {data: wards, code: 1, message: t("common.success")}
  end
end
