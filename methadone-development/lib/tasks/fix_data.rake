namespace :fix_data do
  desc "Task description"
  task init: :environment do
    vouchers = Voucher.all
    vouchers.each do |voucher|
      unless voucher.voucher_medicines.present?
        voucher.destroy
      end
    end
  end
end
