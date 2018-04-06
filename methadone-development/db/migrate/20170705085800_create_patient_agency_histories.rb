class CreatePatientAgencyHistories < ActiveRecord::Migration
  def change
    create_table :patient_agency_histories do |t|
      t.integer    :sender_id
      t.integer    :sender_agency_id
      t.integer    :receiver_agency_id
      t.integer    :status, default: 0
      t.integer    :confirmer_id
      t.datetime   :end_date
      t.references :patient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
