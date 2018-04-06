class PatientContact < ActiveRecord::Base
  belongs_to :patient
  enum contact_type: {father: 0, mother: 1, spouse: 2, sibling: 3, children: 4, other_contact: 5}

  validates :name, presence: true, length: {maximum: 255}
  validates :contact_type, presence: true
  validates :patient_id, presence: true
  validates :address, length: {maximum: 255}
  def self.create_patient_contact (contact_type, name, address_street, address_city, telephone, patient_id)
    self.create(:contact_type => contact_type, :name => name, :address_street => address_street,
      :address_city => address_city, :telephone => telephone, :patient_id => patient_id)
  end
end
