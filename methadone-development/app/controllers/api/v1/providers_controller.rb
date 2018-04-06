class Api::V1::ProvidersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    providers = Provider.actived
    render json: {code: 1, data: providers, message: "success"}
  end

end
