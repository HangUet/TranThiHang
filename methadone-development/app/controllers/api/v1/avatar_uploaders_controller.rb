class Api::V1::AvatarUploadersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    if params[:file].respond_to?('read')
      dir = "#{Rails.root}/public/avatar/"
      new_name = save_file_with_token dir, params[:file]
      render json: {data: "/avatar/" + new_name, code: 1, message: t("common.success")}
    else
      render json: {code: 2, message: t("common.fail")}
    end
  end
end
