class Api::V1::MedicineTypesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    medicine_types = MedicineType.all.select(:id, :name).order(:name)
    render json: {code: 1, data: medicine_types}
  end
end
