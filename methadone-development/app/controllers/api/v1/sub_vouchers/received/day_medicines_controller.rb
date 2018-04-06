class Api::V1::SubVouchers::Received::DayMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @day_medicines = DayMedicine.where(issuing_agency_id: @current_user.issuing_agency_id)
                                .where("remaining > booking")
  end
end
