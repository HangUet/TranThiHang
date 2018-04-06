class Api::V1::DistrictsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    districts = District.select(:id, :name)
                        .where(province_id: params[:province_id])
                        .order(:name)
    render json: {data: districts, code: 1, message: "success"}
  end
end
