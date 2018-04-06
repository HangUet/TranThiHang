namespace :fix_inventory do
  desc "Task description"
  task allocation: :environment do
    day = Date.today - 1.days
    medicine_allocations = MedicineAllocation.where("DATE(allocation_date) = ?", day).where(status: 2)
    medicine_allocations.each do |medicine_allocation|
      if medicine_allocation.medicine_id.nil?
        concentration = 10
      else
        concentration = medicine_allocation.medicine.medicine_list.concentration
      end
      allocate = medicine_allocation.dosage/concentration
      inventory = Inventory.where("DATE(datee) = ?", day)
                          .where(issuing_agency_id: medicine_allocation.user.issuing_agency_id)
                          .where(medicine_id: medicine_allocation.medicine.origin_medicine_id).first
      if inventory.present?
        inventory.update_attributes allocate: inventory.allocate + allocate,
                                    export: inventory.export + allocate
      end
    end
    medicine_allocation_falleds = MedicineAllocation.where("DATE(allocation_date) = ?", day).where(notify_status: 1).where(active: 1)
    medicine_allocation_falleds.each do |medicine_allocation_falled|
      concentration = medicine_allocation_falled.medicine.medicine_list.concentration
      falled = medicine_allocation_falled.dosage/concentration
      update_inventory "falled", day, medicine_allocation_falled.user.issuing_agency_id, falled, medicine_allocation_falled.medicine.origin_medicine_id
    end
  end

  task voucher: :environment do
    day = Date.today - 1.days
    vouchers = Voucher.where("DATE(datee) = ?", day).where(status: 1)
    vouchers.each do |voucher|
      voucher.voucher_medicines.each do |voucher_medicine|
        if voucher.typee == "import_from_distributor"
          update_inventory "import", day, voucher.issuing_agency_id, voucher_medicine.number, voucher_medicine.medicine.id
        elsif voucher.typee == "export_destroy"
          update_inventory "export", day, voucher.issuing_agency_id, voucher_medicine.number, voucher_medicine.medicine.id
        elsif voucher.typee == "export_allocation"
          update_inventory "export_allocate", day, voucher.issuing_agency_id, voucher_medicine.number, voucher_medicine.medicine.id
        elsif voucher.typee == "import_end_day"
          update_inventory "import_end_day", day, voucher.issuing_agency_id, voucher_medicine.number, voucher_medicine.medicine.origin_medicine_id
        end
      end
    end
  end

  task loss: :environment do
    day = Date.today - 1.days
    medicines = Medicine.where(origin_medicine_id: nil).where("DATE(init_date) = ?", day)
    medicines.each do |medicine|
      inventories = Inventory.where(medicine_id: medicine.id)
                            .where(issuing_agency_id: medicine.issuing_agency_id)
                            .where(datee: day)
      inventories.each do |inventory|
        # luong dung thuc te : used, luong dung ly thuyet: inventory.allocate
        loss = 0
        redundancy = 0
        #lượng dùng thực tế = xuất cấp phát - nhập cuối ngày
        used = inventory.export_allocate - inventory.import_end_day
        # x = lượng dùng thực tế - lý thuyết
        x = used - inventory.allocate
        # y = lượng đổ thuốc
        y = inventory.falled
        if x > y
          loss = x
          redundancy = 0
        else
          loss = y
          redundancy = y - x
        end
        inventory.update_attributes loss: loss, redundancy: redundancy
      end
    end
  end

  def update_inventory typee, datee, issuing_agency_id, number, medicine_id
    inventory = Inventory.where(issuing_agency_id: issuing_agency_id,
                               datee: datee, medicine_id: medicine_id).first
    if typee == "import"
      if inventory.present?
        inventory.update_attributes import: (inventory.import + number),
                                    endd: inventory.endd + number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         import: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day + number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn + number,
                                      endd: inventory.endd + number
        end
      end
    elsif typee == "export"
      if inventory.present?
        inventory.update_attributes export: (inventory.export + number),
                                    endd: (inventory.endd - number)
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         export: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day - number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn - number,
                                      endd: inventory.endd - number
        end
      end
    elsif typee == "export_allocate"
      if inventory.present?

        inventory.update_attributes export_allocate: inventory.export_allocate + number,
                                    endd: inventory.endd - number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         export_allocate: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day - number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn - number,
                                      endd: inventory.endd - number
        end
      end
    elsif typee == "import_end_day"
      if inventory.present?

        inventory.update_attributes import_end_day: inventory.import_end_day + number,
                                    endd: inventory.endd + number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day + number,
                         import_end_day: number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn + number,
                                      endd: inventory.endd + number
        end
      end
    elsif typee == "falled" && medicine_id.present?
      if inventory.present?

        inventory.update_attributes falled: inventory.falled + number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         falled: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day
      end
    elsif typee == "not_fall" && medicine_id.present?
      if inventory.present?

        inventory.update_attributes falled: inventory.falled - number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         falled: -number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day
      end
    end
  end
end
