class VoucherMedicine < ActiveRecord::Base
  belongs_to :medicine
  belongs_to :voucher

  validates :number, numericality: {greater_than: 0}
  validates :medicine_id, presence: true
  validates :voucher_id, presence: true

  def self.total
    sum(:number)
  end

  scope :day_import_export, -> day, month, year, type1, type2, issuing_agency_id do
    joins(medicine: :medicine_list).joins(:voucher).where("DAY(datee) = #{day}
      and MONTH(datee) = #{month} and YEAR(datee) = #{year} and
      (typee = #{type1} or typee = #{type2}) and vouchers.issuing_agency_id = ?",
      issuing_agency_id).select(:production_batch, :expiration_date,
      "medicine_lists.source", :typee, :number, :receiver, :sender, "vouchers.issuing_agency_id")
  end

  scope :total_day_ie, -> day, month, year, type, issuing_agency_id do
    joins(:voucher).where("DAY(datee) = #{day}
      and MONTH(datee) = #{month} and YEAR(datee) = #{year}
      and vouchers.issuing_agency_id = ? and typee = ?", issuing_agency_id, type)
      .select("sum(number) as sum")
  end

  scope :get_total_voucher_group_by_source, -> issuing_agency_id {
    joins(:voucher).joins(medicine: :medicine_list)
      .where("vouchers.issuing_agency_id = ?", issuing_agency_id)
      .select("SUM(number) as total, source")
      .group("medicine_lists.source")
  }

  scope :get_import, -> (month, year) {
    where("MONTH(datee) = ? and YEAR(datee) = ? and typee = ?",
      month, year,
      Voucher.typees[:import_from_allocation_agency])
  }
end
