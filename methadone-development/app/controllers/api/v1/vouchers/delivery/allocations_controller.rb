class Api::V1::Vouchers::Delivery::AllocationsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def create
    medicines = params[:voucher][:medicines]

    if medicines == nil
      render json: {code: 2, message: "Không có thuốc trong phiếu."}
      return
    end

    # check thuoc loi. toi uu sau

    # medicines.each do |medicinex|
    #   medicine = Medicine.accepted.find_by id: medicinex[:id]
    #   if medicine
    #     number_order = medicinex[:number]
    #     number = medicine.remaining_number - medicine.booking - number_order
    #     if number >= 0
    #     else
    #       render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
    #       return
    #     end
    #   end
    # end

    last_voucher = Voucher.where(issuing_agency_id: current_user.issuing_agency_id,
                                 typee: Voucher.typees["export_allocation"])
                          .order(code: :desc).first
    if last_voucher.present?
      fk_voucher_code = "X_CSCP_#{current_user.issuing_agency.code}_#{(last_voucher.code.split('_').last.to_i + 1).to_s.rjust(6, '0')}"
    else
      fk_voucher_code = "X_CSCP_#{current_user.issuing_agency.code}_000001"
    end

    medicines.each do |medicinex|
      next if Date.parse(change_date_format(medicinex[:init_date])) <= Date.parse(change_date_format(params[:voucher][:datee]))
      render json: {code: 2, message: "Có thuốc mà ngày tạo lớn hơn ngày xuất phiếu"}
      return
    end

    voucher = Voucher.new(voucher_params.merge(datee: params[:voucher][:datee],
                                               status: :pending,
                                               user_id: current_user.id,
                                               issuing_agency_id: current_user.issuing_agency_id,
                                               typee: :export_allocation,
                                               code: fk_voucher_code))

    if voucher.save

      medicines.each do |medicinex|
        medicine = Medicine.main.accepted.find_by id: medicinex[:id]
        if medicine
          number_order = medicinex[:number]
          voucher_medicine = VoucherMedicine.create number: number_order,
                                                    medicine_id: medicine.id, voucher_id: voucher.id

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

  def change_date_format date_d_m_y
    date_d_m_y.split("/").reverse.join("/")
  end
end
