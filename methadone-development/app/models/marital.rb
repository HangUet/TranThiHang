class Marital < ActiveRecord::Base
  enum status: {deactived: 0, actived: 1}

end
