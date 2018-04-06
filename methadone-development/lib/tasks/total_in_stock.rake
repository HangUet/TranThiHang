namespace :total_in_stock do
  task init: :environment do
    month = (Date.today + 1.months).month
    year = (Date.today + 1.months).year
    medicines_in_stock = Medicine.joins(:medicine_list).group("medicine_lists.source").sum(:remaining_number)
    expire_next_month = Medicine.joins(:medicine_list).group("medicine_lists.source")
      .where("MONTH(expiration_date) = ? and YEAR(expiration_date) = ?", month, year)
      .sum(:remaining_number)
    medicines_in_stock.each do |medicine|
      total_expire = 0
      expire_next_month.each do |expire|
        if medicine[0] == expire[0]
          total_expire = expire[1]
        end
        TotalInventory.create save_date: DateTime.now, total: medicine[1], source: medicine[0],
          expire_next_month: total_expire
      end
    end
  end
end
