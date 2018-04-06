class IssuingAgency < ActiveRecord::Base
  before_destroy :check_constrain
  belongs_to :province
  belongs_to :district
  belongs_to :ward

  has_many :patients
  has_many :users
  has_one :patient_sequence, dependent: :destroy

  validates :name, length: 1..80
  validates :code, presence: true
  validates :address, presence: true
  validates :ward_id, presence: true
  validates :district_id, presence: true
  validates :province_id, presence: true

  private
  def check_constrain
    if users.present? || patients.present?
      errors[:base] << "Không thể xóa do đơn vị này hiện có người dùng hoặc bệnh nhân"
      return false
    end
  end
end
