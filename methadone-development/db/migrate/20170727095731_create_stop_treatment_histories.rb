class CreateStopTreatmentHistories < ActiveRecord::Migration
  def change
    create_table :stop_treatment_histories do |t|
      t.datetime :stop_time
      t.string :reason
      t.references :patient, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
