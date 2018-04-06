class Api::V1::Users::PasswordsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def update
    user = User.find_by(id: params[:id])
    if check_token user, params[:token]
      user.assign_attributes password: params[:password], reset_password_sent_at: nil,
        reset_password_token: nil
      if user.save
        auth_token = JsonWebToken.encode(user_id: user.id)
        render json: {code: 1, message: t("devise.passwords.updated"),
          user: user, token: auth_token}
      else
        render json: {code: 2, message: t("devise.passwords.updated_not_active")}
      end
    else
      render json: {code: 2, message: t("devise.passwords.no_token")}
    end
  end

  def create
    user = User.find_by email: user_params[:email]
    if user.present?
      user.send_reset_password_instructions
      render json: {code: 1, message: t("devise.passwords.send_instructions")}
    else
      render json: {code: 0, message: t("errors.messages.email_not_found")}
    end
  end

  private

  def user_params
    params.require(:user).permit :email
  end

  def check_token user, token
    return user.present? && token.present? && user.reset_password_token.present? &&
      user.reset_password_token == token
  end
end
