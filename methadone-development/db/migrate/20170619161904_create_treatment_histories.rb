class CreateTreatmentHistories < ActiveRecord::Migration
  def change
    create_table :treatment_histories do |t|
      t.datetime :treatment_date
      t.integer :dosage
      t.boolean :syndrome
      t.boolean :drug_poisoning
      t.boolean :urine_test
      t.boolean :use_opium_substance
      t.string :other_opium_substance
      t.string :arv_treatment
      t.string :swap_syringe
      t.string :provide_condom
      t.string :counseling_support
      t.text :note
      t.references :patient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
