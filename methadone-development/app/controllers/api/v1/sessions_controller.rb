class Api::V1::SessionsController < ApplicationController
  before_action :load_user_authentication
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    @auth_token = JsonWebToken.encode(user_id: @user.id)
  end

  private
  def user_params
    # params.require(:user).permit :username, :password
    params.require(:user).permit :email, :password
  end
end
