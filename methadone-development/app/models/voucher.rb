class Voucher < ActiveRecord::Base
  enum typee: {export_in: 0, export_out: 1, import_in: 2, import_from_allocation_agency: 3,
    import_from_distributor: 4 , export_destroy: 5, nurse_import: 6, nurse_export: 7, export_allocation: 8, import_end_day: 9}
  enum status: {pending: 0, accepted: 1}
  # enum division: {pending: 0, accepted: 1}

  has_many :medicines, through: :voucher_medicines
  has_many :voucher_medicines, dependent: :destroy

  belongs_to :issuing_agency
  belongs_to :user

  validates :typee, presence: true
  validates :sender, presence: true
  validates :receiver, presence: true
  validates :issuing_agency_id, presence: true

  ransacker :datee do
    Arel.sql("date(vouchers.datee)")
  end

  scope :all_medicine, -> issuing_agency_id, date_start, date_end, provider_id, invoice_number {
    joins(voucher_medicines: [medicine: [:medicine_list, :provider]])
      .where("vouchers.issuing_agency_id = :issuing_agency_id
        and vouchers.typee = 4
        and DATE(vouchers.datee) >= :date_start
        and DATE(vouchers.datee) <= :date_end
        and (:invoice_number is null or vouchers.invoice_number = :invoice_number)
        and (:provider_id is null or medicines.provider_id= :provider_id)
        and vouchers.status = 1",
        issuing_agency_id: issuing_agency_id, date_start: date_start, date_end: date_end,
        provider_id: provider_id, invoice_number: invoice_number
      ).select("medicine_lists.*", "voucher_medicines.number", "medicines.production_batch",
       "medicines.expiration_date", "providers.name as provider")
  }

  class << self
    def import_export_day month, year, issuing_agency_id
      result = []
      number_day = Time.days_in_month month, year
      today = Date.today
      1.upto(number_day) do |day|
        export_medicine = Voucher.export_in
          .where(issuing_agency_id: issuing_agency_id)
          .where("DAY(datee) = #{day} and MONTH(datee) = #{month} and YEAR(datee) = #{year}")
        number_export = total_number export_medicine
        import_medicine = Voucher.import_in
          .where(issuing_agency_id: issuing_agency_id)
          .where("DAY(datee) = #{day} and MONTH(datee) = #{month} and YEAR(datee) = #{year}")
        number_import = total_number import_medicine
        medicine_allocations = MedicineAllocation.joins(:user)
          .where("users.issuing_agency_id = ?", issuing_agency_id)
          .where("DAY(allocation_date) = #{day} and MONTH(allocation_date) = #{month} and YEAR(allocation_date) = #{year}")
          .sum(:dosage)
        total = number_export - number_import
        sender = export_medicine.present? ? export_medicine.first.sender : nil
        receiver = export_medicine.present? ? export_medicine.first.receiver : nil
        loss = MedicineAllocation.joins(:user)
          .where("users.issuing_agency_id = ?", issuing_agency_id)
          .where("DAY(allocation_date) = #{day} and MONTH(allocation_date) = #{month} and YEAR(allocation_date) = #{year}
          and notify_status = ?", MedicineAllocation.notify_statuses[:falled]).sum(:dosage)
        if total - medicine_allocations > 0
          redundancy = 0
        else
          redundancy = medicine_allocations - total
        end
        date_time = Date.strptime("#{day}/#{month}/#{year}", "%d/%m/%Y")
        if date_time > today
          object = {
            export_medicine: "-",
            import_medicine: "-",
            medicine_allocations_success: "-",
            redundancy: "-",
            loss: "-",
            total: "-",
            sender: "-",
            receiver: "-",
            day: "#{day}/#{month}/#{year}",
            month: "#{month}/#{year}"
          }
        else
          object = {
            export_medicine: number_export,
            import_medicine: number_import,
            medicine_allocations_success: medicine_allocations,
            redundancy: redundancy,
            loss: loss,
            total: total,
            sender: sender,
            receiver: receiver,
            day: "#{day}/#{month}/#{year}",
            month: "#{month}/#{year}"
          }
        end
        result << object
      end
      result
    end

    def total_inventory month, year, issuing_agency_id
      result = []
      number_day = Time.days_in_month month, year
      today = Date.today
      1.upto(number_day) do |day|
        early_day = TotalInventory.where("DAY(save_date) = #{day} and MONTH(save_date) = #{month} and YEAR(save_date) = #{year}").sum(:total)
        export_medicine = Voucher.export_out
          .where("DAY(datee) = #{day} and MONTH(datee) = #{month} and YEAR(datee) = #{year}")
        number_export = total_number export_medicine
        import_medicine = Voucher.import_from_allocation_agency
          .where("DAY(datee) = #{day} and MONTH(datee) = #{month} and YEAR(datee) = #{year}")
        number_import = total_number import_medicine
        medicine_allocations = MedicineAllocation.joins(:user)
          .where("users.issuing_agency_id = ?", issuing_agency_id)
          .where("DAY(allocation_date) = #{day} and MONTH(allocation_date) = #{month} and YEAR(allocation_date) = #{year}")
          .sum(:dosage)
        batch = VoucherMedicine.joins(:voucher, :medicine)
          .select("medicines.production_batch")
          .where("DAY(datee) = #{day}
            and MONTH(datee) = #{month} and YEAR(datee) = #{year} and
            (typee = 1 or typee = 3) and vouchers.issuing_agency_id = ?",
            issuing_agency_id).pluck(:production_batch)
        date_time = Date.strptime("#{day}/#{month}/#{year}", "%d/%m/%Y")
        if date_time <= today
          object = {
            early_day: early_day,
            import_in_day: number_import,
            export_and_use: number_export + medicine_allocations,
            end_day: early_day + number_import - number_export - medicine_allocations,
            batch: batch.join(", "),
            day: "#{day}/#{month}/#{year}",
            month: "#{month}/#{year}"
          }
        else
          object = {
            early_day: "-",
            import_in_day: "-",
            export_and_use: "-",
            end_day: "-",
            batch: "-",
            day: "#{day}/#{month}/#{year}",
            month: "#{month}/#{year}"
          }
        end
        result << object
      end
      result
    end

    def total_number array
      number = 0
      array.each { |a| number += a.voucher_medicines.total }
      number
    end

    def get_loss_redundancy_month month, year, issuing_agency_id
      import_in_month = Voucher.joins(:voucher_medicines).import_in
        .where("MONTH(datee) = ? and YEAR(datee) = ?", month, year)
        .sum(:number).to_i
      export_in_month = Voucher.joins(:voucher_medicines).export_in
        .where("MONTH(datee) = ? and YEAR(datee) = ?", month, year)
        .sum(:number).to_i
      medicine_allocation = MedicineAllocation.joins(:user)
        .where("users.issuing_agency_id = ?", issuing_agency_id)
        .where("MONTH(allocation_date) = ? and YEAR(allocation_date) = ?", month, year)
        .sum(:dosage).to_i
      loss = MedicineAllocation.joins(:user)
        .where("users.issuing_agency_id = ?", issuing_agency_id)
        .where("MONTH(allocation_date) = ? and YEAR(allocation_date) = ? and notify_status = ?",
        MedicineAllocation.notify_statuses[:falled], month, year)
        .sum(:dosage).to_i
      total = export_in_month - import_in_month
      if total - medicine_allocation > 0
        redundancy = 0
      else
        redundancy = medicine_allocation - total
      end
      result = { loss: loss, redundancy: redundancy}
    end

    def get_report_store month, year, issuing_agency_id
      next_month = (Date.new(year, month, 1) + 1.months).month
      next_year = (Date.new(year, month, 1) + 1.months).year
      day_begin_month = Date.new(year, month, 1).beginning_of_month.day
      day_end_month = Date.new(year, month, 1).end_of_month.day

      source_medicines = Medicine.joins(:medicine_list).distinct.pluck("medicine_lists.source")
      reports_detail = {loss: 0, redundancy: 0, medicine_allocation: 0}
      reports_medicine = []
      reports = []
      source_medicines.each do |source|
        report = {source: source, import: 0, stock_early_month: 0, stock_end_month: 0, expirate_next_month: 0}
        reports_medicine << report
      end

      total_medicine_allocation = MedicineAllocation.get_total(month, year, issuing_agency_id)
      loss_redundancy = Voucher.get_loss_redundancy_month(month, year, issuing_agency_id)
      reports_detail[:loss] = loss_redundancy[:loss]
      reports_detail[:redundancy] = loss_redundancy[:redundancy]
      reports_detail[:medicine_allocation] = total_medicine_allocation

      result = VoucherMedicine.get_total_voucher_group_by_source(issuing_agency_id)
      total_import_this_time = result.get_import(month, year)

      reports_medicine.each do |report|
        total_import_this_time.each do |import_medicine|
          if import_medicine.source == report[:source]
            temp = import_medicine.total.to_i
            report[:import] = temp
          end
        end
      end
      if month.to_i != Time.now.month.to_i || year.to_i != Time.now().year.to_i
        inventory = TotalInventory.get_inventory(day_end_month, month, year)
        early_month = TotalInventory.get_inventory(day_begin_month, month, year)
        reports_medicine.each do |report|
          inventory.each do |inv|
            if inv.source == report[:source]
              report[:expirate_next_month] = inv.expirate_next_month
              report[:stock_end_month] = inv.total
            end
          end

          early_month.each do |stock_early|
            if stock_early.source == report[:source]
              report[:stock_end_month] = stock_early.total
            end
          end
        end
      else
        expirate_next_month = Medicine.joins(:medicine_list).where("MONTH(expiration_date) = ? and YEAR(expiration_date) = ?",
          next_month, next_year).group("medicine_lists.source").sum(:remaining_number)
        early_month = TotalInventory.get_inventory(Date.new(year, month, 1).beginning_of_month.day, month, year)
        stock = Medicine.joins(:medicine_list).group("medicine_lists.source").sum(:remaining_number)
        reports_medicine.each do |report|
          expirate_next_month.each do |expirate|
            if expirate[0] == report[:source]
              report[:expirate_next_month] = expirate[1]
            end
          end

          early_month.each do |stock_early|
            if stock_early.source == report[:source]
              report[:stock_early_month] = stock_early.total
            end
          end

          stock.each do |st|
            if st[0] == report[:source]
              report[:stock_end_month] = st[1]
            end
          end
        end
      end

      reports << reports_detail
      reports << reports_medicine
      return reports
    end
  end
end
