class Api::V1::Users::UsersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def update
    user = @current_user
    if user.valid_password?(params[:current_password])
      user.assign_attributes password: params[:new_password]
      if user.save
        render json: {code: 1, message: t("devise.passwords.updated")}
      else
        render json: {code: 2, message: t("devise.passwords.updated_not_active")}
      end
    else
      render json: {code: 2, message: t("devise.passwords.confirmation")}
    end
  end

  def update_name
    @user = @current_user
    if @user.update_columns(name_params)
      render json: {code: 1, message: "Đổi tên thành công", data: @user}
    else
      render json: {code: 2, message: "Thao tác chưa thành công"}
    end
  end

  def get_prescription_creator
    prescription_creator = [User.roles[:doctor], User.roles[:admin_agency], User.roles[:executive_staff]]
    doctors = IssuingAgency.find_by_id(@current_user.issuing_agency_id).users
      .where(role: prescription_creator)
      .select(:id, :first_name, :last_name)
    render json: {code: 1, data: doctors}
  end

  def get_nurse
    nurses = IssuingAgency.find_by_id(@current_user.issuing_agency_id).users
      .where(role: User.roles[:nurse])
      .select(:id, :first_name, :last_name)
    render json: {code: 1, data: nurses}
  end

  def get_admin_agency
    admin_agency = IssuingAgency.find_by_id(@current_user.issuing_agency_id).users
      .where(role: User.roles[:admin_agency])
      .select(:id, :first_name, :last_name)
    render json: {code: 1, data: admin_agency}
  end

  def get_executive_staff
    executive_staff = IssuingAgency.find_by_id(@current_user.issuing_agency_id).users
      .where(role: User.roles[:executive_staff])
      .select(:id, :first_name, :last_name)
    render json: {code: 1, data: executive_staff}
  end

  def get_list_doctor
    doctors = IssuingAgency.find_by_id(@current_user.issuing_agency_id).users
      .where(role: User.roles[:doctor])
      .select(:id, :first_name, :last_name)
    render json: {code: 1, data: doctors}
  end

  def get_all_users
    users = IssuingAgency.find_by_id(@current_user.issuing_agency_id).users
      .where("role != 'admin'")
    render json: {code: 1, data: users}
  end

  private

  def name_params
    params.require(:user).permit :first_name, :last_name
  end

end
