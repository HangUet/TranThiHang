json.code 1
json.message t("common.success")
json.data @patients_allocation do |patient|
  json.card_number patient.card_number
  json.name patient.name
  arr = Array.new(Time.now.end_of_month.day, "x")
  count_loss_day = MedicineAllocation.where(patient_id: patient.id).where(status: 0).where(notify_status: 0)
                  .where("MONTH(allocation_date) = ? and YEAR(allocation_date) = ?", Time.now.month, Time.now.year)
                  .group("DAY(allocation_date)").to_a.length
  count_dosage_day = 0
  patient.medicine_allocations.allocated.allocate_this_month.each do |medicine_allocation|
    day = medicine_allocation.allocation_date.day.to_i
    arr[day - 1] = medicine_allocation.dosage.to_s
    count_dosage_day = count_dosage_day + medicine_allocation.dosage
  end
  patient.medicine_allocations.where(status: 0).allocate_this_month.each do |medicine_allocation|
    day = medicine_allocation.allocation_date.day.to_i
    arr[day - 1] = "-"
  end
  json.medicine_allocations arr do |dosage|
    json.dosage dosage
  end
  json.count_loss_day count_loss_day
  json.count_dosage_day count_dosage_day.to_s
end
json.totals @totals do |total|
  json.total total
end
json.page do
  json.merge!(per_page: Settings.per_page, page: params[:page],
    total: @patients_allocation.total_entries)
end
