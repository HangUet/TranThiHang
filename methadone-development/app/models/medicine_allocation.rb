class MedicineAllocation < ActiveRecord::Base
  belongs_to :patient
  belongs_to :user
  belongs_to :prescription
  belongs_to :medicine

  validates :patient_id, presence: true
  validates :user_id, presence: true

  enum status: {waiting: 0, allocated: 1, taked: 2}
  enum notify_status: {not_fall: 0, falled: 1, vomited: 2}
  enum typee: {morning: 1, afternoon: 2, day: 3}
  enum vomited_allocation: {unconfirmed: 0, confirmed: 1}
  enum active: {deactived: 0, actived: 1}

  scope :allocate_this_month, -> {
    where('MONTH(allocation_date) = MONTH(NOW()) and YEAR(allocation_date) = YEAR(NOW())')
  }
  scope :allocate_before, -> (day, month, year) {
    where('DAY(allocation_date) = ? and MONTH(allocation_date) = ? and YEAR(allocation_date) = ?', day, month, year)
  }

  scope :sum_allocation, -> (day, month, year, issuing_agency_id) {
    joins(:patient).where("DAY(allocation_date) = #{day}
      and MONTH(allocation_date) = #{month} and YEAR(allocation_date) = #{year}
      and patients.issuing_agency_id = ?", issuing_agency_id).sum(:dosage)
  }

  scope :get_total, -> (month, year, issuing_agency_id) {
    joins(:user).where("users.issuing_agency_id = ?", issuing_agency_id)
    .where('MONTH(allocation_date) = ? and YEAR(allocation_date) = ?', month, year)
    .sum(:dosage)
  }
  scope :allocation_patient, -> month, year, patient_id {
    where("patient_id = ? and
      MONTH(allocation_date) = ? and YEAR(allocation_date) = ?", patient_id,
      month, year).select("DAY(allocation_date) as day, dosage")
  }

  scope :history_allocation_patient, -> from_date, to_date, patient_id {
    where("patient_id = ? and
      DATE(allocation_date) >= ? and DATE(allocation_date) <= ?", patient_id,
      from_date.to_date, to_date.to_date)
  }
end
