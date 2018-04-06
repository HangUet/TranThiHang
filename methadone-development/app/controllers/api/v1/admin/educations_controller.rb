class Api::V1::Admin::EducationsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_education, only: [:show, :update, :destroy]
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    educations = Education.search(name_cont: params[:keyword], status_eq: Education.statuses[params[:keystatus]]).
      result.paginate page: params[:page], per_page: Settings.per_page
    render json: {code: 1, data: educations, per_page: Settings.per_page,
      page: params[:page], total: educations.total_entries, message: "success"}
  end

  def show
    render json: {code: 1, data: @education, message: "success"}
  end

  def create
    check_exist = Education.where(name: params[:education][:name])
    if check_exist.blank?
      education = Education.new education_params
      if education.save
        render json: {code: 1, message: t("admin.category.create_success")}
      else
        render json: {code: 2, message: t("admin.category.create_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.education_create_exist")}
    end
  end

  def update
    check_exist = Education.where(name: params[:education][:name])
      .where(status: Education.statuses[params[:education][:status]])
    if check_exist.blank?
      if @education.update_attributes education_params
        render json: {code: 1, message: t("admin.category.update_success")}
      else
        render json: {code: 2, message: t("admin.category.update_fail")}
      end
    else
      render json: {code: 2, message: t("admin.category.education_create_exist")}
    end
  end

  def destroy
    if @education.update_attributes(status: Education.statuses[:deactived])
      render json: {code: 1, message: t("admin.category.delete_success")}
    else
      render json: {code: 2, message: t("admin.category.delete_fail")}
    end
  end

  private

  def education_params
    params.require(:education).permit(:name, :status)
  end

  def find_education
    @education = Education.find_by id: params[:id]
    render json: {code: 2, message: t("admin.category.not_found")} unless @education
  end
end
