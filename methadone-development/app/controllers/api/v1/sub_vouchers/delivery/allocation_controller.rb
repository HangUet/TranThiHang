class Api::V1::SubVouchers::Delivery::AllocationController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    sub_medicines = params[:sub_voucher][:sub_medicines]

    sub_voucher_params = params[:sub_voucher]
    if sub_medicines == nil
      render json: {code: 2, message: "Không có thuốc trong phiếu."}
      return
    end
    sub_medicines.each do |sub_medicinex|
      sub_medicine = SubMedicine.find_by id: sub_medicinex[:sub_medicine_id]
      number_order = sub_medicinex[:number].to_f

      if sub_medicine.present? && sub_medicine.remaining >= (sub_medicine.booking + number_order)
      else
        render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
        return
      end
    end

    last_sub_voucher = SubVoucher.where(issuing_agency_id: current_user.issuing_agency_id,
                                        typee: SubVoucher.typees[:export_to_allocation])
                                 .order(code: :desc).first

    if last_sub_voucher.present?
      fk_voucher_code = "X_CP_#{current_user.issuing_agency.code}_#{(last_sub_voucher.code.split('_').last.to_i + 1).to_s.rjust(6, '0')}"
    else
      fk_voucher_code = "X_CP_#{current_user.issuing_agency.code}_000001"
    end

    sub_voucher = SubVoucher.new datee: params[:sub_voucher][:datee],
                              typee: SubVoucher.typees[:export_to_allocation],
                              status: :pending,
                              issuing_agency_id: @current_user.issuing_agency_id,
                              sender: sub_voucher_params[:sender],
                              receiver: sub_voucher_params[:receiver],
                              code: fk_voucher_code

    if sub_voucher.save

      sub_medicines.each do |sub_medicinex|
        sub_medicine = SubMedicine.find_by id: sub_medicinex[:sub_medicine_id]
        number_order = sub_medicinex[:number].to_f

        if sub_medicine.present? && sub_medicine.remaining >= (sub_medicine.booking + number_order)
          SubVoucherSubMedicine.create number: number_order,
                                       sub_medicine_id: sub_medicine.id,
                                       sub_voucher_id: sub_voucher.id

          sub_medicine.update_attributes(booking: (sub_medicine.booking + number_order))
        else
          render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
          return
        end
      end
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  def update
    sub_medicines = params[:sub_voucher][:sub_medicines]

    if sub_medicines == nil
      render json: {code: 2, message: "Không có thuốc trong phiếu."}
      return
    end

    sub_voucher_params = params[:sub_voucher]

    sub_voucher = SubVoucher.where(id: sub_voucher_params[:id],
                                   issuing_agency_id: @current_user.issuing_agency_id).first

    if sub_voucher.present?

      sub_voucher.update_attributes sender: sub_voucher_params[:sender],
                                    receiver: sub_voucher_params[:receiver],
                                    datee: sub_voucher_params[:datee]

      sub_medicine_id_from_client = sub_medicines.map{|m| m["sub_medicine_id"]}
      sub_medicine_ids = sub_voucher.sub_medicines.pluck(:id)

      deleted_sub_medicine_ids = sub_medicine_ids - sub_medicine_id_from_client

      deleted_sub_voucher_medicines = SubVoucherSubMedicine.where(sub_voucher_id: sub_voucher.id,
                                                                  sub_medicine_id: deleted_sub_medicine_ids)

      if deleted_sub_voucher_medicines.length > 0
        deleted_sub_voucher_medicines.each do |sub_voucher_medicine|
          temp_sub_medicine = sub_voucher_medicine.sub_medicine
          temp_sub_medicine.update_attributes booking: (temp_sub_medicine.booking - sub_voucher_medicine.number)
          sub_voucher_medicine.destroy
        end
      end

      sub_medicines.each do |sub_medicinex|
        if sub_medicinex[:flag] == "new"

          sub_medicine = SubMedicine.find_by id: sub_medicinex[:id]
          number_order = sub_medicinex[:number_order]

          if sub_medicine && sub_medicine.remaining >= (sub_medicine.booking + number_order)

              SubVoucherSubMedicine.create number: number_order,
                                           sub_medicine_id: sub_medicine.id,
                                           sub_voucher_id: sub_voucher.id

              sub_medicine.update_attributes(booking: (sub_medicine.booking + number_order))
          else
            render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại hoặc không đủ số lượng yêu cầu."}
            return
          end

        else
          sub_medicine = SubMedicine.find_by id: sub_medicinex[:sub_medicine_id]
          if sub_medicine.present?
            number_order = sub_medicinex[:number_order].to_i

            sub_voucher_sub_medicine = SubVoucherSubMedicine.where(sub_medicine_id: sub_medicine.id,
                                                                   sub_voucher_id: sub_voucher.id).first

            if sub_voucher_sub_medicine == nil
              render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
              return
            end

            if (sub_medicine.remaining + sub_voucher_sub_medicine.number) >= (sub_medicine.booking + number_order)
              sub_medicine.update_attributes(booking: (sub_medicine.booking + number_order - sub_voucher_sub_medicine.number))
              sub_voucher_sub_medicine.update_attributes number: number_order
            else
              render json: {code: 2, message: "Phiếu chứa thuốc không đủ số lượng yêu cầu."}
              return
            end

          else
            render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại."}
            return
          end
        end
      end
      render json: {code: 1, message: "Cập nhật thành công."}
    else
      render json: {code: 2, message: "Cập nhật thất bại."}
    end
  end

  private

  def sub_voucher_params
    params.require(:sub_voucher).permit :sender, :receiver, :medicines
  end
end
