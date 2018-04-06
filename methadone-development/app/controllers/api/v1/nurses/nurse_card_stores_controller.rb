class Api::V1::Nurses::NurseCardStoresController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def index
    data = []
    if params[:from_date].present? && params[:to_date].present? && params[:medicine_list_id].present?
      medicines = Medicine.where(medicine_list_id: params[:medicine_list_id],
        issuing_agency_id: current_user.issuing_agency_id)
      medicines.each do |medicine|
        sub_inventory = SubInventory.where(medicine_id: medicine.id)
                                    .where(issuing_agency_id: current_user.issuing_agency_id)
                                    .where("DATE(datee) >= ?", params[:from_date].to_date)
                                    .where("DATE(datee) <= ?", params[:to_date].to_date).first
        if sub_inventory.present?
          used = sub_inventory.export.to_i - sub_inventory.import.to_i
          allocation = MedicineAllocation.where("DATE(allocation_date) >= ?", params[:from_date].to_date)
                                         .where("DATE(allocation_date) <= ?", params[:to_date].to_date)
                                         .sum(:dosage)
          loss = 0
          redundancy = 0
          if allocation.to_i > used
            loss = allocation.to_i - used
          else
            redundancy = used - allocation.to_i
          end
          data.push ({datee: sub_inventory.datee.strftime("%d/%m/%Y"),
                    batch: medicine.production_batch,
                    expiration_date: medicine.expiration_date.strftime("%d/%m/%Y"),
                    beginn: sub_inventory.beginn,
                    import: sub_inventory.import,
                    export: sub_inventory.export,
                    loss: loss,
                    redundancy: redundancy,
                    endd: sub_inventory.endd
                    })
        end
      end
      render json: {code: 1, data: data}
    else
      render json: {code: 2}
    end
  end
end
