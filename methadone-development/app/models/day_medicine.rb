class DayMedicine < ActiveRecord::Base
  validates :remaining, numericality: {greater_than: -1}
  validates :issuing_agency_id, presence: true

  belongs_to :sub_medicine
end
