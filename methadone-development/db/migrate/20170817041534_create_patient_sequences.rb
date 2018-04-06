class CreatePatientSequences < ActiveRecord::Migration
  def change
    create_table :patient_sequences do |t|
      t.integer :number, default: 0
      t.references :issuing_agency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
