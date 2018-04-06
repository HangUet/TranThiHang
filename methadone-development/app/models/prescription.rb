class Prescription < ActiveRecord::Base
  belongs_to :patient
  belongs_to :user
  belongs_to :medicine_list
  has_many :medicine_allocations

  enum close_status: {open: 1, close: 2}
  enum typee: {morning: 1, afternoon: 2, day: 3}
  enum type_treatment: {maintain: 1, detect_the_dose: 2, reduce_the_dose: 3}
  enum show_status: {show: 0, hide: 1}
  before_save :update_type_treatment

  validates :prescription_type, presence: true
  validates :dosage, numericality: {greater_than: 0, less_than_or_equal_to: 1000}
  validates :begin_date, presence: true
  validates :end_date_expected, presence: true
  validates :user_id, presence: true
  validates :patient_id, presence: true

  scope :type_treatment_of_patient, -> patient_id {
    where("patient_id = ? and DATE(begin_date) <= ?", patient_id, Date.today)
      .order(id: :asc).limit(1)
  }

  class << self
    def format_data prescriptions, current_user_id
      result = []
      prescriptions.each do |prescription|
        date = prescription.begin_date.strftime("%d/%m/%Y") rescue nil
        end_date_expected = prescription.end_date_expected.strftime("%d/%m/%Y") rescue nil
        end_date = prescription.end_date.strftime("%d/%m/%Y") rescue nil
        check_edit = true
        if prescription.begin_date.to_date < Date.today || prescription.user_id != current_user_id || prescription.close_status == "close"
          check_edit = false
        end
        if prescription.begin_date.to_date == Date.today
          medicine_allocation = MedicineAllocation
                                  .where(patient_id: prescription.patient_id)
                                  .where("DATE(allocation_date) = ? and status != 0", Date.today)
                                  .where(prescription_id: prescription.id)
          check_edit = false if medicine_allocation.present?
        end
        check_end_date = false
        if Date.strptime(end_date_expected, "%d/%m/%Y") > Date.today && prescription.close_status == "open"
          check_end_date = true
        end
        close_status = prescription.close_status
        if prescription.begin_date.to_date > Date.today && prescription.open?
          close_status = "will_do"
        end
        doctor = prescription.user
        doctor_name = doctor.first_name + " " + doctor.last_name
        object = {
          id:  prescription.id,
          dosage: prescription.dosage,
          begin_date: date,
          end_date_expected: end_date_expected,
          end_date: end_date,
          medication_name: prescription.medicine_list.name,
          medication_composition: prescription.medicine_list.composition,
          prescription_type: prescription.prescription_type,
          patient_id: prescription.patient_id,
          close_status: close_status,
          check_end_date: check_end_date,
          description: prescription.description,
          type_treatment: prescription.type_treatment,
          check_edit: check_edit,
          doctor_name: doctor_name,
          created_at: prescription.created_at,
          updated_at: prescription.updated_at
        }
        result << object
      end
      result
    end
  end

  def update_type_treatment
    if self.type_treatment != 'reduce_the_dose'
      prescription = Prescription.where(patient_id: self.patient_id)
                      .where("DATE(begin_date) <= ?", Date.today).order(begin_date: :asc).last
      if prescription.present? && prescription.type_treatment == "maintain" &&
          self.dosage == prescription.dosage
        self.type_treatment = 1
      else
        time_last = Date.today - Settings.number_day_maintain.days
        presciption_first = Prescription.where(patient_id: self.patient_id).order(begin_date: :asc).first
        if presciption_first.present? && presciption_first.begin_date > time_last
          self.type_treatment = 2
        else
          prescriptions = Prescription.where(patient_id: self.patient_id)
            .where("DATE(begin_date) >= ? and DATE(begin_date) <= ?",
            time_last, Date.today).pluck(:dosage)
          if prescriptions.present?
            prescriptions << self.dosage
            self.type_treatment = prescriptions.uniq.size <= 1 ? 1 : 2
          else
            self.type_treatment = 2
          end
        end
      end
    end
  end

end
