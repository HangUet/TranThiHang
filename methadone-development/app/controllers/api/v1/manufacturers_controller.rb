class Api::V1::ManufacturersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    manufacturers = Manufacturer.actived
    render json: {code: 1, data: manufacturers, message: "success"}
    return
  end

end
