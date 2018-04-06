class Api::V1::Vouchers::Received::ImportNewsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  def create
    medicines = params[:voucher][:medicines]

    # check thuoc khong ton tai. toi uu sau

    medicine_production_batchs = medicines.map{|m| [m[:name], m[:composition], m[:concentration],
      m[:packing], m[:provider], m[:production_batch], m[:expiration_date], m[:price]]}
    if medicine_production_batchs.uniq.length != medicine_production_batchs.length
      render json: {code: 2, message: "Trong phiếu chứa thuốc trùng lô."}
      return
    end

    medicines.each do |medicinex|
      medicine = MedicineList.find_by id: medicinex[:id]

      unless medicine.present?
        render json: {code: 2, message: "Phiếu chứa một số thuốc không tồn tại."}
        return
      end
    end

    if medicines == nil
      render json: {code: 2, message: "Không có thuốc trong phiếu."}
      return
    end

    voucher_params = params[:voucher]

    unless voucher_params[:total_money] < 20000000000
      render json: {code: 2, message: "Tổng tiền quá lớn."}
      return
    end

    provider = Provider.where(id: voucher_params[:provider_id]).first

    unless provider.present?
      render json: {code: 2, message: "Nhà sản xuất không đúng."}
      return
    end

    last_voucher = Voucher.where(issuing_agency_id: current_user.issuing_agency_id,
                                 typee: Voucher.typees["import_from_distributor"])
                          .order(code: :desc).first
    if last_voucher.present?
      fk_voucher_code = "N_NPP_#{current_user.issuing_agency.code}_#{(last_voucher.code.split('_').last.to_i + 1).to_s.rjust(6, '0')}"
    else
      fk_voucher_code = "N_NPP_#{current_user.issuing_agency.code}_000001"
    end

    voucher = Voucher.new datee: voucher_params[:datee],
                          sender: voucher_params[:sender],
                          receiver: voucher_params[:receiver],
                          identification_card_sender: voucher_params[:identification_card_sender],
                          status: :pending,
                          total_money: voucher_params[:total_money],
                          issuing_agency_id: current_user.issuing_agency_id,
                          user_id: current_user.id,
                          typee: :import_from_distributor,
                          invoice_number: voucher_params[:invoice_number],
                          code: fk_voucher_code
    if voucher.save

      new_medicines = []

      medicines.each do |medicinex|
        medicine = MedicineList.find_by id: medicinex[:id]

        if medicinex[:number].blank?
          render json: {code: 2, message: t("medicine.create.fails")}
          return
        end

        if medicine.present?
          new_medicines.push ({medicine_list_id: medicine.id,
                               expiration_date: medicinex[:expiration_date],
                               production_batch: medicinex[:production_batch],
                               number: medicinex[:number],
                               price: medicinex[:price],
                               voucher_id: voucher.id})
        else
          render json: {code: 2, message: "Phiếu chứa một số thuốc không tồn tại."}
          return
        end
      end

      new_medicines.each do |medicinex|
        medicine = Medicine.new issuing_agency_id: @current_user.issuing_agency_id,
                                expiration_date: medicinex[:expiration_date],
                                production_batch: medicinex[:production_batch],
                                remaining_number: medicinex[:number],
                                medicine_list_id: medicinex[:medicine_list_id],
                                provider_id: provider.id,
                                source: voucher_params[:source],
                                price: medicinex[:price],
                                status: :pending,
                                division: :main,
                                init_date: voucher_params[:datee]

        if medicine.save
          voucher_medicine = VoucherMedicine.create number: medicinex[:number],
                                                  medicine_id: medicine.id, voucher_id: voucher.id

        else
          render json: {code: 2, message: t("medicine.create.fails")}
          return
        end

      end

      render json: {code: 1, message: t("medicine.create.success")}
    else
      render json: {code: 2, message: t("medicine.create.fails")}
    end
  end
end
