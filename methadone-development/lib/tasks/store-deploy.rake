namespace :haha do
  task free: :environment do
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0; ")
    ActiveRecord::Base.connection.execute("TRUNCATE voucher_medicines")
    ActiveRecord::Base.connection.execute("TRUNCATE vouchers")
    ActiveRecord::Base.connection.execute("TRUNCATE medicines")
    ActiveRecord::Base.connection.execute("TRUNCATE medicine_lists")
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1;")
  end
end
