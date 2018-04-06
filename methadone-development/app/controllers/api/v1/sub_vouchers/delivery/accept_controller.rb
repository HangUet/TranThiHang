class Api::V1::SubVouchers::Delivery::AcceptController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def update

    # Tim phieu xuat tra lai
    # Kiem tra phieu chua xac nhan va ton tai

    @sub_voucher = SubVoucher.find_by_id (params[:id])

    unless @sub_voucher.present?
      render json: {code: 2, message: "Không tìm thấy phiếu."}
      return
    end

    if @sub_voucher.status == "accepted" || @sub_voucher.status == "inprocess"
      render json: {code: 2, message: "Phiếu đã xác nhận không thể xác nhận."}
      return
    end

    unless @sub_voucher.sub_medicines.first.present?
      render json: {code: 2, message: "Không thể xác nhận phiếu không có thuốc."}
      return
    end
    total_number = 0
    if @sub_voucher.typee == "export_to_allocation"
      accept_allocation
      # total_number = @sub_voucher.sub_voucher_sub_medicines.sum(:number)
      # # cap nhap sub_inventory
      # @sub_voucher.sub_voucher_sub_medicines.each do |sub_voucher_sub_medicine|
      #   update_sub_inventory "export", @sub_voucher.datee.to_date.strftime,
      #     @sub_voucher.issuing_agency_id, total_number, sub_voucher_sub_medicine.sub_medicine.medicine.id
      #   update_inventory "export_day", @sub_voucher.datee.to_date.strftime,
      #     @sub_voucher.issuing_agency_id, sub_voucher_sub_medicine.number, sub_voucher_sub_medicine.sub_medicine.medicine.id
      # end
    else
      accept_give_back
    end

  end

  private

  def accept_give_back

    # Tao voucher nhap cho quan ly kho voi thuoc
      # Tao voucher_medicines cho voucher
      # Cap nhat trang thai cua sub_voucher

    last_voucher = Voucher.where(issuing_agency_id: current_user.issuing_agency_id,
                                 typee: Voucher.typees["import_from_allocation_agency"])
                          .order(code: :desc).first

    if last_voucher.present?
      fk_voucher_code = "N_CSCP_#{current_user.issuing_agency.code}_#{(last_voucher.code.split('_').last.to_i + 1).to_s.rjust(6, '0')}"
    else
      fk_voucher_code = "N_CSCP_#{current_user.issuing_agency.code}_000001"
    end

    voucher = Voucher.create datee: @sub_voucher.datee,
                             status: :pending,
                             issuing_agency_id: current_user.issuing_agency_id,
                             typee: :import_from_allocation_agency,
                             sender: @sub_voucher.sender,
                             receiver: @sub_voucher.receiver,
                             code: fk_voucher_code

    sub_medicines = @sub_voucher.sub_medicines

    if sub_medicines.length > 0
      sub_medicines.each do |sub_medicine|

        sub_voucher_sub_medicine = SubVoucherSubMedicine.where(sub_medicine_id: sub_medicine.id,
                                                               sub_voucher_id: @sub_voucher.id).first

        if sub_voucher_sub_medicine.present?

          VoucherMedicine.create medicine_id: sub_medicine.medicine_id,
                                 number: sub_voucher_sub_medicine.number,
                                 voucher_id: voucher.id

          # sub_medicine.update_attributes remaining: (sub_medicine.remaining - sub_voucher_sub_medicine.number),
          #                                booking: (sub_medicine.booking - sub_voucher_sub_medicine.number)
        else
          render json: {code: 2, message: "Không tìm thấy thuốc này. Vui lòng F5 và tạo lại phiếu."}
          return
        end
      end
    else
      render json: {code: 2, message: "Không thể xác nhận phiếu không có thuốc."}
      return
    end

    @sub_voucher.update_attributes status: SubVoucher.statuses[:inprocess], voucher_id: voucher.id
    render json: {code: 1, message: "Cập nhật thành công."}
    return
  end

  def accept_allocation

    # Tim phieu xuat cap phat
    # Kiem tra phieu chua xac nhan va ton tai
    # Voi moi thuoc trong phieu se tao mot day_medicine (thuoc de cap phat trong ngay)
    # Cap nhat booking va remaining cua sub_medicine
    # Cap nhat trang thai cua phieu

    sub_medicines = @sub_voucher.sub_medicines

    if sub_medicines.length > 0
      sub_medicines.each do |sub_medicine|

        sub_voucher_sub_medicine = SubVoucherSubMedicine.where(sub_medicine_id: sub_medicine.id,
                                                               sub_voucher_id: @sub_voucher.id).first

        if sub_voucher_sub_medicine.present?

          DayMedicine.create sub_medicine_id: sub_medicine.id,
                                            sub_voucher_id: @sub_voucher.id,
                                            remaining: sub_voucher_sub_medicine.number,
                                            issuing_agency_id: @current_user.issuing_agency_id,
                                            init_date: @sub_voucher.datee


          sub_medicine.update_attributes remaining: (sub_medicine.remaining - sub_voucher_sub_medicine.number),
                                         booking: (sub_medicine.booking - sub_voucher_sub_medicine.number)
        else
          render json: {code: 2, message: "Không tìm thấy thuốc này. Vui lòng F5 và tạo lại phiếu."}
          return
        end
      end
    end

    @sub_voucher.update_attributes status: 1 # accepted
    render json: {code: 1, message: "Cập nhật thành công."}
    return
  end
end
