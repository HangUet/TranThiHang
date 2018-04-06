class Api::V1::AdminAgency::UsersController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token
  before_action :find_user, only: [:show, :update, :destroy]

  respond_to :json

  def index
    user = User.active.where("issuing_agency_id = ? and role != ?", @current_user.issuing_agency_id, "admin")
      .search(full_name_or_email_cont: params[:keyword]).result
      .paginate page: params[:page],per_page: Settings.per_page
    render json: {code: 1, message: "", data: User.user_structure(user),
      per_page: Settings.per_page, page: params[:page], total: user.total_entries}
  end

  def show
    render json: {code: 1, data: @user}
  end

  def create
    if User.find_by(email: user_params[:email])
      render json: {:code => 2, message: t("devise.registrations.username")}
      return
    end
    user = User.new user_params
    user.assign_attributes is_active: 1
    if user.save
      render json: {:code => 1, message: t("devise.registrations.success")}
    else
      render json: {:code => 2, message: user.errors.full_messages[0]}
    end
  end

  def update

    if User.where("id <> ?", params[:id]).find_by(email: user_params[:email])
      render json: {:code => 2, message: t("devise.registrations.username")}
      return
    end

    @user.attributes = user_params
    if user_params[:password].present?
      @user.unlock_token = nil
      @user.failed_attempts = 0
      @user.locked_at = nil
    end
    if @user.save(validate: false)
      render json: {code: 1, message: t("users.show.edit_link.update_success")}
    else
      render json: {code: 2, message: t("users.show.edit_link.update_fail")}
    end
  end

  def destroy
    if @user.update_attribute :is_active, 0
      render json: {code: 1, message: t("admin.user_index.delete_success")}
    else
      render json: {code: 2, message: t("admin.user_index.delete_fail")}
    end
  end

  private

  def find_user
    @user = User.find_by id: params[:id]

    if @user.blank?
      render json: {code: 2, message: "Không tìm thấy người dùng"}
    end
  end

  def user_params
    # params[:user][:role] = Settings.role.doctor
    params[:user][:issuing_agency_id] = @current_user.issuing_agency_id
    params.require(:user).permit :username, :password, :email, :first_name,
      :last_name, :issuing_agency_id, :role
  end
end
