class Api::V1::Vouchers::Received::EndDayController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def create
    medicines = params[:voucher][:medicines]

    last_voucher = Voucher.where(issuing_agency_id: current_user.issuing_agency_id,
                                 typee: Voucher.typees["import_end_day"])
                          .order(code: :desc).first
    if last_voucher.present?
      fk_voucher_code = "N_NPP_#{current_user.issuing_agency.code}_#{(last_voucher.code.split('_').last.to_i + 1).to_s.rjust(6, '0')}"
    else
      fk_voucher_code = "N_NPP_#{current_user.issuing_agency.code}_000001"
    end

    voucher_params = params[:voucher]

    voucher = Voucher.new datee: voucher_params[:datee],
                          sender: voucher_params[:sender],
                          receiver: voucher_params[:receiver],
                          status: :pending,
                          issuing_agency_id: current_user.issuing_agency_id,
                          user_id: current_user.id,
                          typee: :import_end_day,
                          code: fk_voucher_code
    if voucher.save

      medicines.each do |medicinex|
        medicine = Medicine.allocation.where(id: medicinex["id"]).first

        if medicine.present?
          VoucherMedicine.create medicine_id: medicinex["id"], voucher_id: voucher.id, number: medicinex["number"]
        else
          render json: {code: 2, message: "Phiếu chứa thuốc không tồn tại"}
          return
        end
      end

      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end
end
