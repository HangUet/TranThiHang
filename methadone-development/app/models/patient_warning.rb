class PatientWarning < ActiveRecord::Base
  belongs_to :patient

  enum status: {open: 1, close: 0}
  enum level: {obligatory: 1, optional: 0}

  validates :patient_id, presence: true
end
