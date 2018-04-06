class Api::V1::Allocations::MedicinesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def index
    @medicine_lists = MedicineList.all

    data = []

    @medicine_lists.each do |medicine_list|

      remaining = 0

      medicines = Medicine.where(issuing_agency_id: current_user.issuing_agency_id,
                                 medicine_list_id: medicine_list.id).pluck(:id)
      if medicines.present?

        sub_medicine = SubMedicine.where(issuing_agency_id: current_user.issuing_agency_id,
                                         medicine_id: medicines).sum(:remaining)
        if sub_medicine.present?
          remaining = sub_medicine
        end
      end
      data.push ({id: medicine_list.id,
                  name: medicine_list.name,
                  composition: medicine_list.composition,
                  manufacturer: medicine_list.manufacturer,
                  concentration: medicine_list.concentration,
                  remaining: remaining
                  })
    end
    render json: {code: 1, data: data}
  end
end
