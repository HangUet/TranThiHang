class SubVoucher < ActiveRecord::Base
  has_many :sub_medicines, through: :sub_voucher_sub_medicines
  has_many :sub_voucher_sub_medicines, dependent: :destroy

  belongs_to :issuing_agency

  enum typee: {export_to_allocation: 0, export_to_give_back: 1, import_end_day: 2, import_from_main_agency: 3}
  enum status: {pending: 0, accepted: 1, inprocess: 2, rejected: 3}
end
