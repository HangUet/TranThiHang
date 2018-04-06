class Api::V1::Selections::MedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    if params[:division] == "main"

      @medicines = Medicine.main.accepted
                           .where("issuing_agency_id = ? and remaining_number > 0", @current_user.issuing_agency_id)
    elsif params[:division] == "allocation"
      if params[:init_date].present?
        @medicines = Medicine.allocation.accepted
                             .where("issuing_agency_id = ? and remaining_number > 0 and init_date = ?",
                             @current_user.issuing_agency_id, params[:init_date])
      else
        @medicines = Medicine.allocation.accepted
                           .where("issuing_agency_id = ? and remaining_number > 0", @current_user.issuing_agency_id)
      end
    else
      @medicines = Medicine.accepted
                           .where("issuing_agency_id = ? and remaining_number > 0", @current_user.issuing_agency_id)
    end
  end
end
