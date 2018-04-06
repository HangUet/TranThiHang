class Api::V1::SampleUsersController < ApplicationController
  before_action :authenticate_request!, only: :destroy
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    data = []
    admin = User.admin.first
    admin_agency = User.admin_agency.first
    doctor = User.doctor.first
    nurse = User.nurse.first
    storekeeper = User.storekeeper.first
    executive_staff = User.executive_staff.first
    data = [admin, admin_agency, doctor, nurse, storekeeper, executive_staff]
    render json: {data: return_data(data), code: 1, message: t("common.success")}
  end

  def destroy
    user = User.find_by id: params[:id]
    if user.destroy
      render json: {code: 1, message: "Xóa tài khoản thành công"}
    else
      render json: {code: 2, message: "Xóa tài khoản thất bại"}
    end
  end

  private

  def return_data array
    result = []
    role = ["Quản trị hệ thống", "Trưởng cơ sở", "Bác sĩ", "Cấp phát thuốc", "Quản lý kho", "Nhân viên hành chính"]
    array.each_with_index do |data, index|
      if data.present?
        object = {
          email: data.email,
          role: role[index]
        }
        result << object
      end
    end
    result
  end

end
