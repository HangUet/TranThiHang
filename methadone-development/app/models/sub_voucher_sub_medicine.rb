class SubVoucherSubMedicine < ActiveRecord::Base
  belongs_to :sub_medicine
  belongs_to :sub_voucher

end
