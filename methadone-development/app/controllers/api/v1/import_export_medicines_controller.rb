class Api::V1::ImportExportMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    if params[:day]
      month = params[:day].split("/")[0].to_i
      year = params[:day].split("/")[1].to_i
      data = Voucher.import_export_day(month, year, @current_user.issuing_agency_id)
    else
      month = Time.now.month
      year = Time.now.year
      data = Voucher.import_export_day(month, year, @current_user.issuing_agency_id)
    end
    render json: {code: 1, data: data}
  end
end
