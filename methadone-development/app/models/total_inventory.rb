class TotalInventory < ActiveRecord::Base
  scope :get_inventory, -> (day, month, year) {
    where("DAY(save_date) = ? and MONTH(save_date) = ? and YEAR(save_date) = ?",
      day, month, year)
    .group("source")
  }
end
