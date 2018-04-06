class Api::V1::SubVouchers::SubMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @sub_voucher = SubVoucher.where(id: params[:sub_voucher_id],
                                   issuing_agency_id: @current_user.issuing_agency_id).first

    @sub_medicines = @sub_voucher.sub_medicines.where("remaining > booking");
  end

end
