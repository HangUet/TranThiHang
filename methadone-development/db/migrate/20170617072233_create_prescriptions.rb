class CreatePrescriptions < ActiveRecord::Migration
  def change
    create_table :prescriptions do |t|
      t.float :dosage
      t.datetime :begin_date
      t.datetime :end_date
      t.datetime :end_date_expected
      t.string :medication_name
      t.string :prescription_type
      t.integer :close_status
      t.float :dosage_morning
      t.integer :type_treatment
      t.text :description
      t.references :user, index: true, foreign_key: true
      t.references :patient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
