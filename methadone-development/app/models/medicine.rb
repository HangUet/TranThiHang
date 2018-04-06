class Medicine < ActiveRecord::Base

  enum status: {pending: 0, accepted: 1}
  enum division: {main: 0, allocation: 1}

  has_many :voucher_medicines, dependent: :destroy
  has_many :sub_medicines
  has_many :vouchers, through: :voucher_medicines
  has_many :sub_inventories
  has_many :inventories
  has_many :medicine_allocations

  belongs_to :medicine_list
  belongs_to :provider

  validates :production_batch, presence: true, length: 1..255
  validates :expiration_date, presence: true
  # validates :remaining_number, numericality: {greater_than: -1}
  validates :price, presence: true
  validates :issuing_agency_id, presence: true

  before_save :check_remaining_number

  def check_remaining_number
    self.remaining_number = 0 if self.remaining_number < 0
  end
end
