class Api::V1::StoreReports::InventoriesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def show
    if params[:day]
      month = params[:day].split("/")[0].to_i
      year = params[:day].split("/")[1].to_i
      data = Inventory.where("YEAR(datee) = #{year} and MONTH(datee) = #{month}")
    else
      month = Time.now.month.to_i
      year = Time.now.year.to_i
      data = Inventory.where("YEAR(datee) = #{year} and MONTH(datee) = #{month}")
    end
    render json: {code: 1, data: data, year: "#{year}", month: "#{month}"}
  end
end
