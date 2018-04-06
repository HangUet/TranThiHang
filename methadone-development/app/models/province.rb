class Province < ActiveRecord::Base
  has_many :districts
  has_many :patients
end
