json.code 1
json.message t("common.success")
json.data @patients_change do |patient|
  json.card_number patient.card_number
  json.name patient.name
  json.dosage patient.dosage
  before_dosage = 0
  if params[:date]
    before_dosage = patient.medicine_allocations.allocate_before(@day.to_i - 1, @month, @year).first.dosage
    json.before_dosage before_dosage
  else
    before_dosage = patient.medicine_allocations.allocate_before(Time.now.day - 1, Time.now.month, Time.now.year).first.dosage
    json.before_dosage before_dosage
  end
  change = patient.dosage - before_dosage
  json.increase change > 0 ? change : nil
  json.decrease change < 0 ? -change : nil
end
