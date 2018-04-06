class Api::V1::Admin::UsersController < ApplicationController
  # before_action :require_admin
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token
  before_action :find_user, only: [:show, :update, :destroy]

  respond_to :json

  def index
    admin_agency = User.active.admin_agency.in_agencies(params[:issuing_agency_id])
      .search(full_name_or_email_cont: params[:keyword]).result
      .paginate page: params[:page],per_page: Settings.per_page

    render json: {code: 1, messeage: "", data: User.user_structure(admin_agency),
      per_page: Settings.per_page, page: params[:page], total: admin_agency.total_entries}
  end

  def show
    render json: {code: 1, data: @user}
  end

  def create
    if User.find_by(email: user_params[:email])
      render json: {:code => 2, message: t("devise.registrations.username")}
      return
    end
    return render json: {code: 2, message: "Please select agency"} unless params[:user][:issuing_agency_id]
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

    if params[:user][:issuing_agency_id]
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
    else
      render json: {code: 2, message: t("admin.user_index.not_issuing_agency")}
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
    params[:user][:role] = Settings.role.admin_agency
    params.require(:user).permit :username, :password, :email, :first_name,
      :last_name, :issuing_agency_id, :role
  end
end
