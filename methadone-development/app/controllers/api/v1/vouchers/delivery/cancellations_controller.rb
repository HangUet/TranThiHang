class Api::V1::Vouchers::Delivery::CancellationsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def create
    medicines = params[:voucher][:medicines]

    if medicines == nil
      render json: {code: 2, message: "Không có thuốc trong phiếu."}
      return
    end

    # check thuoc loi. toi uu sau

    medicines.each do |medicinex|
      medicine = Medicine.accepted.find_by id: medicinex[:id]
      if medicine
        number_order = medicinex[:number]

        number = medicine.remaining_number - medicine.booking - number_order

        if number >= 0
        else
          render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
          return
        end
      end
    end

    last_voucher = Voucher.where(issuing_agency_id: current_user.issuing_agency_id,
                                 typee: Voucher.typees["export_destroy"])
                          .order(code: :desc).first
    if last_voucher.present?
      fk_voucher_code = "X_HUY_#{current_user.issuing_agency.code}_#{(last_voucher.code.split('_').last.to_i + 1).to_s.rjust(6, '0')}"
    else
      fk_voucher_code = "X_HUY_#{current_user.issuing_agency.code}_000001"
    end

    voucher = Voucher.new(voucher_params.merge(datee: params[:voucher][:datee],
                                               status: :pending,
                                               user_id: current_user.id,
                                               issuing_agency_id: current_user.issuing_agency_id,
                                               typee: :export_destroy,
                                               code: fk_voucher_code))

    if voucher.save

      medicines.each do |medicinex|
        medicine = Medicine.accepted.find_by id: medicinex[:id]
        if medicine
          number_order = medicinex[:number]
          voucher_medicine = VoucherMedicine.create number: number_order,
                                                    medicine_id: medicine.id,
                                                    voucher_id: voucher.id

          number = medicine.remaining_number - medicine.booking - number_order

          if number >= 0
            medicine.update_attributes(booking: (medicine.booking + number_order))
          else
            render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
            return
          end
        end
      end
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  private

  def voucher_params
    params.require(:voucher).permit :sender, :receiver, :agency_sender_receiver, :medicines
  end
end
