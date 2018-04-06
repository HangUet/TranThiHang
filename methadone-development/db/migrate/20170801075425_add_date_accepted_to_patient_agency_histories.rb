class AddDateAcceptedToPatientAgencyHistories < ActiveRecord::Migration
  def change
    add_column :patient_agency_histories, :date_accepted, :datetime
  end
end
