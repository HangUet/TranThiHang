class District < ActiveRecord::Base
  belongs_to :province
  has_many :patients
  has_many :wards
end
