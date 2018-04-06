class Api::V1::MedicineReceivedController < ApplicationController
  before_action :authenticate_request!
  before_action :load_medicine_voucher, :check_owner, only: [:show, :update, :destroy]
  before_action :load_voucher, :can_create, :check_duplicate, only: [:create]
  before_action :can_update, only: [:update]
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def index
    @voucher = Voucher.find_by(id: params[:voucher_id], issuing_agency_id: current_user.issuing_agency_id)
    if @voucher.nil?
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end
    @voucher_medicines = VoucherMedicine.where(voucher_id: params[:voucher_id])
  end

  def show
  end

  def create
    if @voucher.typee == "import_from_distributor"
      medicine = Medicine.new medicine_params.merge(issuing_agency_id: @current_user.issuing_agency_id, status: :pending)
      if medicine.save
        VoucherMedicine.create(medicine_id: medicine.id, number: params[:medicines][:remaining_number],
          voucher_id: params[:medicines][:voucher_id])

        render json: {code: 1, message: t("medicine.create.success")}
      else
        render json: {code: 2, message: t("medicine.create.fails")}
      end
    elsif @voucher.typee == "import_from_allocation_agency"
      medicine = Medicine.find_by id: medicine_params[:medicine_list_id]
      if medicine.present?
        VoucherMedicine.create medicine_id: medicine.id, number: medicine_params[:remaining_number], voucher_id: @voucher.id
        render json: {code: 1, message: "Thêm thuốc thành công."}
        return
      else
        render json: {code: 2, message: "Không có thuốc này."}
        return
      end
    end
  end

  def update
    if @voucher_medicine.voucher.medicines.find_by production_batch: medicine_params[:production_batch]
      render json: {code: 2, message: "Số lô trùng."}
      return
    end

    if @voucher_medicine.update_attributes(number: medicine_params[:remaining_number])
      @voucher_medicine.medicine.update_attributes(medicine_params)
      render json: {code: 1, message: "Cập nhật thành công"}
    else
      render json: {code: 2, message: "Cập nhật thất bại"}
    end
  end

  def destroy
    if @voucher_medicine.medicine.destroy
      if @voucher_medicine.destroy
        render json: {code: 1, message: "Xóa thành công"}
      else
        render json: {code: 2, message: "Xóa thất bại"}
      end
    else
      render json: {code: 2, message: "Xóa thất bại"}
    end
  end

  private

  def medicine_params
    params.require(:medicines).permit :medicine_list_id, :expiration_date,
      :production_batch, :remaining_number
  end

  def load_voucher
    @voucher = Voucher.find_by(id: params[:medicines][:voucher_id], issuing_agency_id: current_user.issuing_agency_id)
    if @voucher == nil
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end
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
    if @voucher.issuing_agency_id != current_user.issuing_agency_id
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end
    if @voucher.status == "accepted"
      render json: {code: 2, message: "Phiếu đã được xác nhận. Không được thêm thuốc."}
      return
    end
  end

  def check_duplicate
    if @voucher.medicines.find_by production_batch: medicine_params[:production_batch]
      render json: {code: 2, message: "Lô thuốc đã tồn tại trong phiếu, vui lòng sửa số lượng thuốc."}
      return
    end
  end

  def check_owner
    if @voucher_medicine.voucher.issuing_agency_id != current_user.issuing_agency_id
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end
  end
end
