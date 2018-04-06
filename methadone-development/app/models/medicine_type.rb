class MedicineType < ActiveRecord::Base
  has_many :medicine_list
end
