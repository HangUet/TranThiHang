class Api::V1::VouchersController < ApplicationController
  before_action :authenticate_request!

  before_action :load_voucher, only: [:show, :update, :destroy]
  before_action :can_change, only: [:update, :destroy]

  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # def index
  #   if params[:type] == "1" #xuat
  #     typees = [0, 1, 5, 8]
  #   else
  #     typees = [2, 3, 4]
  #   end
  #   @vouchers = Voucher.order(created_at: :desc)
  #                      .where(issuing_agency_id: @current_user.issuing_agency_id, typee: typees)
  # end

  def show
    if params[:type] == "with_medicines"
      @medicines = @voucher.medicines
    end
  end

  def create
    voucher = Voucher.new(voucher_params.merge(datee: Time.now, status: :pending,
      issuing_agency_id: current_user.issuing_agency_id))

    medicines = params[:voucher][:medicines]

    medicines.each do |medicinex|
      medicine = Medicine.accepted.find_by id: medicinex[:id]
      if medicine
        number_order = medicinex[:number]
        voucher_medicine = VoucherMedicine.create number: medicinex[:number], medicine_id: medicinex[:id]

        number = medicine.remaining_number - medicine.booking - number_order

        if number > 0
          medicine.update_attributes(booking: (medicine.booking + number_order))
        else
          render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
          return
        end
      end
    end

    if voucher.save
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  private

  def load_voucher
    @voucher = Voucher.find_by(id: params[:id])
  end

  def voucher_params
    params.require(:voucher).permit :typee, :sender, :receiver, :agency_sender_receiver
  end

  def can_change
    if @voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã được xác nhận. Không được thay đổi."}
      return
    end
  end
end
