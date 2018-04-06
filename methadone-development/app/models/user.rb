class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :recoverable, :confirmable, :lockable, :trackable
  include ModelHelper
  belongs_to :issuing_agency
  has_many :notifications
  has_many :stop_treatment_histories
  has_many :medicine_allocations
  has_many :prescriptions
  has_many :report_creator
  has_many :vouchers

  devise :database_authenticatable, :recoverable, :lockable, :trackable

  before_create :update_user_name

  validates :username, :length => { :maximum => 50 }

  enum role: [:admin, :admin_agency, :doctor, :nurse, :executive_staff, :counselor,
              :analyzer, :storekeeper, :health_department, :AIDS_department]
  enum is_active: {active: 1, deactivate: 0}
  PASSWORD_FORMAT = /\A(?=.{8,})(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[A-z0-9!@#$%^&*])/x
  validates :password, format: { with: PASSWORD_FORMAT }

 ransacker :full_name do |parent|
    Arel::Nodes::NamedFunction.new('CONCAT_WS', [
      Arel::Nodes.build_quoted(' '), parent.table[:first_name], parent.table[:last_name]
    ])
  end
  def active?
    status == "active"
  end

  def active_for_authentication?
    super and self.is_active?
  end

  scope :in_agencies, lambda {|issuing_agency_id|
    where(issuing_agency_id: issuing_agency_id) if issuing_agency_id.present?
  }

  def update_user_name
    first_name = self.last_name.squish.split(" ") rescue ''
    last_name = self.first_name.squish.split(" ") rescue ''
    prefix = ''
    last_name.each do |string|
      prefix += string.first.downcase
    end
    user_name = "#{remove_unicode(first_name.last)}#{prefix}"
    user = User.where username: user_name

    if user.present?
      user_name += User.last.id.to_s
    end
    self.username = user_name
  end

  class << self
    def user_structure list_user
      result = Array.new
      list_user.each do |user|
        object = {
          id: user.id,
          email: user.email,
          full_name: "#{user.first_name} #{user.last_name}",
          role: user.role,
          issuing_agency: user.issuing_agency.name
        }
        result << object
      end
      result
    end
  end

end
