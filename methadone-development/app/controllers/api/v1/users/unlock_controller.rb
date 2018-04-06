class Api::V1::Users::UnlockController < ApplicationController
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    if params[:email].present?
      user = User.find_by email: params[:email]
      if user.present?
        user.send_unlock_instructions
        render json: {code: 1, message: t("devise.unlocks.send_instructions")}
      else
        render json: {code: 2, message: t("common.no_email")}
      end
    else
      user = User.find_by id: params[:user]
      if user.unlock_token == params[:unlock_token]
        user.unlock_access!
        render json: {code: 1, message: "Tài khoản của bạn đã được mở khóa"}
      end
    end
  end
end
