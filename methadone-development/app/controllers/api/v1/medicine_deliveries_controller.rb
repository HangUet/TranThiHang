class Api::V1::MedicineDeliveriesController < ApplicationController
  before_action :authenticate_request!
  before_action :load_medicine_voucher, only: [:show, :update, :destroy]
  before_action :can_update, only: [:update, :destroy]

  before_action :can_create, :check_duplicate, only: [:create]

  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def index
    @voucher = Voucher.select(:id, :status, :user_id).find_by id: params[:voucher_id]
    if @voucher.present?
      @voucher_medicines = @voucher.voucher_medicines
    end
  end

  def show
    render json: {code: 1, data: @voucher_medicine}
  end

  def create
    number_order = medicine_params[:number].to_f
    voucher_medicine = VoucherMedicine.new medicine_params

    medicine = Medicine.accepted.find_by id: medicine_params[:medicine_id]

    if medicine

      number = medicine.remaining_number - medicine.booking - number_order

      if number > 0
        medicine.update_attributes(booking: (medicine.booking + number_order))
      else
        render json: {code: 2, message: "Không đủ số lượng yêu cầu"}
        return
      end
    end
    if voucher_medicine.save
      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end

  def update
    number_order = medicine_params[:number].to_f

    booking = @voucher_medicine.medicine.booking - @voucher_medicine.number + number_order

    if booking < @voucher_medicine.medicine.remaining_number
      @voucher_medicine.update_attributes number: number_order
      @voucher_medicine.medicine.update_attributes booking: booking
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Không đủ thuốc để xuất"}
    end
  end

  def destroy
    booking = @voucher_medicine.medicine.booking - @voucher_medicine.number
    medicine = @voucher_medicine.medicine

    if @voucher_medicine.destroy
      medicine.update_attributes booking: booking
      render json: {code: 1, message: "Xóa thành công"}
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def medicine_params
    params.require(:medicines).permit :voucher_id, :number, :medicine_id
  end

  def load_medicine_voucher
    @voucher_medicine = VoucherMedicine.find_by(id: params[:id])
  end

  def can_update
    if @voucher_medicine.voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã được xác nhận. Không được sửa."}
      return
    end
  end

  def can_create
    @voucher = Voucher.find_by id: medicine_params[:voucher_id]
    if @voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã được xác nhận. Không được thêm thuốc."}
      return
    end
  end

  def check_duplicate
    medicine_id = medicine_params[:medicine_id]
    if VoucherMedicine.find_by medicine_id: medicine_id, voucher_id: medicine_params[:voucher_id]
      render json: {code: 2, message: "Thuốc đã tồn tại trong phiếu, vui lòng sửa số lượng thuốc"}
      return
    end
  end
end
