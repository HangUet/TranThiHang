class SubMedicine < ActiveRecord::Base
  enum status: {pending: 0, accepted: 1}

  has_many :sub_vouchers, through: :sub_voucher_sub_medicines
  has_many :sub_voucher_sub_medicines, dependent: :destroy
  has_many :day_medicines

  belongs_to :medicine
  belongs_to :issuing_agency

  validates :remaining, numericality: {greater_than: -1}
  validates :issuing_agency_id, presence: true

end
