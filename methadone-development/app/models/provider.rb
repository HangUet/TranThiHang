class Provider < ActiveRecord::Base
  enum status: {deactived: 0, actived: 1}
  has_many :medicines
end
