namespace :vouchers do

  task update_typee: :environment do
    Voucher.where(typee: [0, 1]).update_all typee: 8
    Medicine.all.update_all status: 1
  end

  desc "Task description"
  task init: :environment do
    medicine_allocations = Prescription.open.joins(:user)
                            .where("DATE(allocation_date) = ?", Date.today)
                            .group("users.issuing_agency_id")
                            .sum(:dosage)
    medicine_allocations.each do |key, value|
      daily_export = Voucher.create(status: 0, typee: 7, datee: Time.now,
        issuing_agency_id: key)
      daily_import = Voucher.create(status: 0, typee: 6, datee: Time.now,
        issuing_agency_id: key)
      medicines = Medicine.where(issuing_agency_id: key)
        .where("remaining_number > 0 and DATE(expiration_date) >= ?", Date.today)
        .order(expiration_date: :asc)
      medicines.each do |medicine|
        if medicine.remaining_number < value
          VoucherMedicine.create(voucher_id: daily_export.id,
            medicine_id: medicine.id, number: medicine.remaining_number)
          # medicine.update_attributes(remaining_number: 0)
          value -= medicine.remaining_number
        elsif value > 0
          VoucherMedicine.create(voucher_id: daily_export.id,
            medicine_id: medicine.id, number: value)
          tmp = medicine.remaining_number - value
          # medicine.update_attributes(remaining_number: tmp)
          value = 0
        end
      end
    end
  end
end
