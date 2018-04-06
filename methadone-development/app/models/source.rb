class Source < ActiveRecord::Base
  enum status: {deactived: 0, actived: 1}
  
end
