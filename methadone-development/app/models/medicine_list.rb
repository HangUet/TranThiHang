class MedicineList < ActiveRecord::Base
  enum status: {deactived: 0, actived: 1}
  has_many :medicines
  has_many :prescriptions
  belongs_to :medicine_type

  validates :name, length: 1..255
  validates :composition, presence: true
  validates :concentration, presence: true
  validates :packing, presence: true
  validates :manufacturer, length: 1..255, allow_nil: true
  validates :unit, length: 1..255
end
