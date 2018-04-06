class StopTreatmentHistory < ActiveRecord::Base
  belongs_to :patient
  belongs_to :user

  QUERRY_STOP_TREATMENT =  "id in (SELECT stop_treatment_histories.id FROM stop_treatment_histories
    inner join (SELECT max(id) as id, patient_id FROM
    stop_treatment_histories GROUP BY patient_id) as s
    ON s.id = stop_treatment_histories.id
    inner join patients ON s.patient_id = patients.id
    where patients.issuing_agency_id = :issuing_agency_id
    and patients.active = 0 and DATE(stop_treatment_histories.stop_time) >= :date_start
    and DATE(stop_treatment_histories.stop_time) <= :date_end
    and stop_treatment_histories.reason = :reason)"

  QUERRY_STOP_TREATMENT_ALL = "id in (SELECT stop_treatment_histories.id FROM stop_treatment_histories
    inner join (SELECT max(id) as id, patient_id FROM
    stop_treatment_histories GROUP BY patient_id) as s
    ON s.id = stop_treatment_histories.id
    inner join patients ON s.patient_id = patients.id
    where patients.issuing_agency_id = :issuing_agency_id
    and patients.active = 0 and DATE(stop_treatment_histories.stop_time) >= :date_start
    and DATE(stop_treatment_histories.stop_time) <= :date_end)"

  QUERRY_STOP_TREATMENT_AND_COME_BACK = "id in (SELECT stop_treatment_histories.id FROM stop_treatment_histories
    inner join (SELECT max(id) as id, patient_id FROM
    stop_treatment_histories GROUP BY patient_id) as s
    ON s.id = stop_treatment_histories.id
    inner join patients ON s.patient_id = patients.id
    where patients.issuing_agency_id = :issuing_agency_id
    and patients.active = 1 and DATE(stop_treatment_histories.stop_time) >= :date_start
    and DATE(stop_treatment_histories.stop_time) <= :date_end)"

  scope :stop_treatment, ->issuing_agency_id, date_start, date_end, reason {
    where(QUERRY_STOP_TREATMENT, issuing_agency_id: issuing_agency_id,
      date_start: date_start, date_end: date_end, reason: reason).count
  }

  scope :stop_treatment_all, ->issuing_agency_id, date_start, date_end{
    where(QUERRY_STOP_TREATMENT_ALL, issuing_agency_id: issuing_agency_id,
      date_start: date_start, date_end: date_end).count
  }

  scope :stop_treatment_and_come_back, ->issuing_agency_id, date_start, date_end{
    where(QUERRY_STOP_TREATMENT_AND_COME_BACK, issuing_agency_id: issuing_agency_id,
      date_start: date_start, date_end: date_end).count
  }
end
