class PatientAgencyHistory < ActiveRecord::Base
  belongs_to :patient
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :sender_agency, class_name: "IssuingAgency", foreign_key: "sender_agency_id"
  belongs_to :receiver_agency, class_name: "IssuingAgency", foreign_key: "receiver_agency_id"
  belongs_to :confirmer, class_name: "User", foreign_key: "confirmer_id"

  enum status: {pending: 0, refused: 1, accepted: 2, cancelled: 3, expiration_soon: 4}

  validates :status, presence: true
  validates :sender_id, presence: true
  validates :sender_agency_id, presence: true
  validates :patient_id, presence: true

  QUERRY_CHANGE_AGENCY_SEND_BEFORE =  "id in (SELECT patient_agency_histories.id FROM patient_agency_histories
    inner join (SELECT max(id) as id, patient_id FROM
    patient_agency_histories WHERE receiver_agency_id = :issuing_agency_id GROUP BY patient_id) as p
    ON p.id = patient_agency_histories.id
    inner join patients ON p.patient_id = patients.id
    where patients.issuing_agency_id = :issuing_agency_id
    and patients.active = 1 and DATE(patient_agency_histories.date_accepted) >= :date_start
    and DATE(patient_agency_histories.date_accepted) <= :date_end
    and DATE(patients.admission_date) < :date_start)"

  QUERRY_CHANGE_AGENCY_SEND_IN =  "id in (SELECT patient_agency_histories.id FROM patient_agency_histories
    inner join (SELECT max(id) as id, patient_id FROM
    patient_agency_histories WHERE receiver_agency_id = :issuing_agency_id GROUP BY patient_id) as p
    ON p.id = patient_agency_histories.id
    inner join patients ON p.patient_id = patients.id
    where patients.issuing_agency_id = :issuing_agency_id
    and patients.active = 1 and DATE(patient_agency_histories.date_accepted) >= :date_start
    and DATE(patient_agency_histories.date_accepted) <= :date_end
    and DATE(patients.admission_date) >= :date_start
    and DATE(patients.admission_date) <= :date_end)"

  scope :change_agency, -> issuing_agency_id, date_start, date_end {
    where("receiver_agency_id = ? and DATE(date_accepted) >= ? and DATE(date_accepted) <= ?",
      issuing_agency_id, date_start, date_end)
  }

  scope :change_agency_before, -> issuing_agency_id, date_start, date_end {
    where(QUERRY_CHANGE_AGENCY_SEND_BEFORE, issuing_agency_id: issuing_agency_id, date_start: date_start,
      date_end: date_end).count
  }

  scope :change_agency_in, -> issuing_agency_id, date_start, date_end {
    where(QUERRY_CHANGE_AGENCY_SEND_IN, issuing_agency_id: issuing_agency_id, date_start: date_start,
      date_end: date_end).count
  }
end
