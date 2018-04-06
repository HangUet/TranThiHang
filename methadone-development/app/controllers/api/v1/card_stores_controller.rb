class Api::V1::CardStoresController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    data = []
    if params[:from_date].present? && params[:to_date].present? && params[:medicine_list_id].present?
      medicines = Medicine.where(medicine_list_id: params[:medicine_list_id],
        issuing_agency_id: current_user.issuing_agency_id).where(origin_medicine_id: nil)
      medicines.each do |medicine|
        inventories = Inventory.where(medicine_id: medicine.id)
                                    .where(issuing_agency_id: current_user.issuing_agency_id)
                                    .where("DATE(datee) >= ?", params[:from_date].to_date)
                                    .where("DATE(datee) <= ?", params[:to_date].to_date)
        if inventories.present?
          inventories.each do |inventory|
              # luong dung thuc te : used, luong dung ly thuyet: inventory.allocate
            loss = 0
            redundancy = 0
            #lượng dùng thực tế = xuất cấp phát - nhập cuối ngày
            used = inventory.export_allocate - inventory.import_end_day
            # x = lượng dùng thực tế - lý thuyết
            x = used - inventory.allocate
            # y = lượng đổ thuốc
            y = inventory.falled
            if x > y
              loss = x
              redundancy = 0
            else
              loss = y
              redundancy = y - x
            end
            inventory.update_attributes loss: loss, redundancy: redundancy
            data.push ({datee: inventory.datee.strftime("%d/%m/%Y"),
                      batch: medicine.production_batch,
                      expiration_date: medicine.expiration_date.strftime("%d/%m/%Y"),
                      beginn: inventory.beginn,
                      import: inventory.import,
                      export: inventory.export,
                      loss: loss,
                      redundancy: redundancy,
                      endd: inventory.endd
                      })
          end
        end
      end
      data = data.sort_by { |a| a[:datee].to_date }
      render json: {code: 1, data: data}
    else
      render json: {code: 2}
    end
  end

  def get_loss_reduncy
    if params[:time_type] == "day"
      if params[:type] = "loss"
        inventories = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                      .where("DATE(datee) = ?", params[:time].to_date).sum(:loss)
                      render json: {code: 1, data: inventories}
      elsif params[:type] = "redundancy"
        inventories = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                      .where("DATE(datee) = ?", params[:time].to_date).sum(:redundancy)
      end

    elsif params[:time_type] == "month"

      redundancy = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                    .where("MONTH(datee) = ?", params[:time].to_date.month).sum(:redundancy)

      loss = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                    .where("MONTH(datee) = ?", params[:time].to_date.month).sum(:loss)

      total_allocation = MedicineAllocation.joins(:user).where("users.issuing_agency_id = ?", current_user.issuing_agency_id)
                         .where("status != 0 or notify_status != 0").sum(:dosage)
      list_medicine = Medicine.where(issuing_agency_id: current_user.issuing_agency_id)
                      .where("MONTH(init_date) = ?", params[:time].to_date.month)
                      .select(:production_batch, :expiration_date)
      render json: {code: 1, redundancy: redundancy, loss: loss, list_medicine: list_medicine,
                    total_allocation: total_allocation}
    end

  end
end
