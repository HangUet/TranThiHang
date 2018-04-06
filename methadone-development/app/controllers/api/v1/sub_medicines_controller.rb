class Api::V1::SubMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @sub_medicines = SubMedicine.where(issuing_agency_id: @current_user.issuing_agency_id)
  end

  def show
    @sub_medicine = SubMedicine.where(id: params[:id], issuing_agency_id: @current_user.issuing_agency_id).first
  end

end
