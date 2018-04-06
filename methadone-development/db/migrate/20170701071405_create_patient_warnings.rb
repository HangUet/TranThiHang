class CreatePatientWarnings < ActiveRecord::Migration
  def change
    create_table :patient_warnings do |t|
      t.string :content
      t.integer :level
      t.integer :status
      t.references :patient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
