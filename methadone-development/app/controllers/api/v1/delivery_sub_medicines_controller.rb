class Api::V1::DeliverySubMedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    @sub_medicines = SubVoucher.find_by_id(params[:sub_voucher_id]).sub_medicines
    @medicines = Medicine.where(id: @sub_medicines.pluck(:medicine_id))
    @medicine_list = MedicineList.where(id: @medicines.pluck(:medicine_list_id))
    @sub_medicine_sub_voucher = SubVoucherSubMedicine.where(sub_medicine_id: @sub_medicines.pluck(:id)).pluck(:number)
  end

  def show
    @sub_medicine = SubMedicine.first
  end
end
