class Patient < ActiveRecord::Base
  belongs_to :issuing_agency
  belongs_to :ethnicity
  belongs_to :district
  belongs_to :province
  belongs_to :ward
  belongs_to :resident_province, class_name: "Province", foreign_key: "resident_province_id"
  belongs_to :resident_district, class_name: "District", foreign_key: "resident_district_id"
  belongs_to :resident_ward, class_name: "Ward", foreign_key: "resident_ward_id"
  has_many :treatment_histories
  has_many :patient_contacts
  has_many :patient_warnings
  has_many :medicine_allocations
  has_many :patient_agency_histories
  has_many :prescriptions
  has_many :stop_treatment_histories
  attr_accessor :ethnicity_name, :district_name, :province_name

  enum active: {deactived: 0, actived: 1, deleted: 2}
  enum identification_type: {identity_card: 0, household_registration_book: 1,
    driving_license: 2, passport: 3}

  validates :card_number, uniqueness: true
  validates :name, presence: true, length: {maximum: 255}
  validates :birthdate, presence: true
  validates :gender, presence: true
  validates :mobile_phone, format: {with: /^0[0-9]{9,11}$/, multiline: true}, allow_blank: true
  validates :identification_number, presence: true
  validates :identification_type, presence: true
  validates :address, length: {maximum: 255}
  validates :hamlet, length: {maximum: 255}
  validates :resident_address, length: {maximum: 255}
  validates :resident_hamlet, length: {maximum: 255}
  # validates_uniqueness_of :identification_type, :scope => :identification_number
  validates :identification_issued_date, presence: true
  validates :identification_issued_by, presence: true, length: {maximum: 255}
  validates :admission_date, presence: true
  # validates :referral_agency, presence: true, length: {maximum: 255}
  validates :issuing_agency_id, presence: true
  validates :province_id, presence: true
  validates :district_id, presence: true
  validate :check_admission_date, :admission_date
  validate :check_admission_date_prescription, :admission_date

  scope :get_allocation, -> (day, month, year, issuing_agency_id){
    joins(:medicine_allocations)
      .where("issuing_agency_id = ? and DAY(allocation_date) = #{day}
      and MONTH(allocation_date) = #{month} and YEAR(allocation_date) = #{year}", issuing_agency_id)
      .select(:id, :card_number, :name, :dosage)
  }

  scope :get_allocation_day, -> (issuing_agency_id) {
    joins(:medicine_allocations).where("MONTH(allocation_date) = MONTH(NOW())
      and YEAR(allocation_date) = YEAR(NOW())").where(issuing_agency_id: issuing_agency_id)
      .where("medicine_allocations.status = 2").select("DAY(allocation_date) as day, sum(dosage) as sum").group("day")
  }

  scope :not_deleted, -> {
    where.not(active: 2)
  }

  scope :is_deactived, -> issuing_agency_id, date_start, date_end {
    where("active = 0 and issuing_agency_id = :issuing_agency_id
      and (:date_start is null or (DATE(patients.updated_at) >= :date_start))
      and (:date_end is null or (DATE(patients.updated_at) <= :date_end))",
      issuing_agency_id: issuing_agency_id, date_start: date_start, date_end: date_end)
  }

  scope :stop_treatment, -> issuing_agency_id, date_start, date_end {
    joins(:stop_treatment_histories).where("active = 1 and
      issuing_agency_id = ? and stop_treatment_histories.patient_id
      is not null and DATE(patients.updated_at) >= ? and DATE(patients.updated_at) <= ?",
      issuing_agency_id, date_start, date_end)
  }

  scope :being_treated, -> issuing_agency_id, date_start, date_end {
    where("active = 1 and issuing_agency_id = :issuing_agency_id
      and (:date_start is null or (DATE(patients.admission_date) >= :date_start))
      and (:date_end is null or (DATE(patients.admission_date) <= :date_end))",
      issuing_agency_id: issuing_agency_id, date_start: date_start, date_end: date_end)
  }

  QUERRY_PATIENT = "id in (SELECT patients.id from patients
    inner join (SELECT max(id) as prescription_id, patient_id FROM prescriptions GROUP BY patient_id) as p
    ON p.patient_id = patients.id
    inner join (SELECT id, user_id FROM prescriptions) as p2
    ON p2.id = p.prescription_id
    inner join users ON p2.user_id = users.id
    WHERE patients.issuing_agency_id = :issuing_agency_id and patients.active = 1 and p2.user_id is not null
    and users.issuing_agency_id = :issuing_agency_id
    and (:date_start is null or (DATE(patients.updated_at) >= :date_start))
    and (:date_end is null or (DATE(patients.updated_at) <= :date_end)))"

  QUERRY_PATIENT_OLD = "id in (SELECT patients.id FROM patients
    WHERE patients.issuing_agency_id = :issuing_agency_id
    AND patients.active = 1
    AND (:date_start is null or (DATE(patients.admission_date) < :date_start)))"

  # QUERRY_PATIENT_STOP_BEFORE_TIME = "id in (SELECT "


  QUERRY_PATIENT_NEW = "id in (SELECT patients.id FROM patients
    WHERE patients.issuing_agency_id = :issuing_agency_id
    and patients.active = 1
    and (:date_start is null or (DATE(patients.admission_date) >= :date_start))
    and (:date_end is null or (DATE(patients.admission_date) <= :date_end)))"

  scope :patient_old, -> issuing_agency_id, date_start, date_end {
    where(QUERRY_PATIENT_OLD, issuing_agency_id: issuing_agency_id,
      date_start: date_start).count
  }

  scope :patient_new, -> issuing_agency_id, date_start, date_end {
    where(QUERRY_PATIENT_NEW, issuing_agency_id: issuing_agency_id,
      date_start: date_start, date_end: date_end).count
  }

  scope :patient_stop_in_time, -> issuing_agency_id, date_start, date_end {
    joins(:issuing_agency, :stop_treatment_histories).
      where("issuing_agencies.id = :issuing_agency_id and patients.active = 0
        and (DATE(stop_treatment_histories.stop_time) > :date_start)",
        issuing_agency_id: issuing_agency_id, date_start: date_start, date_end: date_end)
      .distinct(:patient_id).count
  }

  scope :change_agency_after, -> issuing_agency_id, date_start, date_end {
    joins(:issuing_agency, :patient_agency_histories).
      where("issuing_agencies.id <> :issuing_agency_id and patients.active = 1
        and DATE(patient_agency_histories.date_accepted) > :date_start
        and patient_agency_histories.sender_agency_id = :issuing_agency_id",
        issuing_agency_id: issuing_agency_id, date_start: date_start).distinct(:patient_id).count
  }

  def ethnicity_name
    self.ethnicity.name if self.ethnicity_id.present?
  end

  def district_name
    self.district.name if self.district_id.present?
  end

  def province_name
    self.province.name if self.province_id.present?
  end

  def check_admission_date
    if admission_date.to_date <= birthdate.to_date
      errors.add("Ngày vào điều trị", " phải lớn hơn ngày sinh")
    end
  end

  def check_admission_date_prescription
    if self.prescriptions.present?
      if self.admission_date.to_date > self.prescriptions.first.begin_date.to_date
        errors.add("Ngày vào điều trị", " phải nhỏ hơn ngày kê đơn thuốc")
      end
    end
  end
end
