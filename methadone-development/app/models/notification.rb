class Notification < ActiveRecord::Base
  belongs_to :user
  enum status: {unseen: 0, seen: 1}
end
