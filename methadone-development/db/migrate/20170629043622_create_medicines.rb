class CreateMedicines < ActiveRecord::Migration
  def change
    create_table :medicines do |t|
      t.datetime :expiration_date
      t.string :production_batch
      t.integer :remaining_number
      t.integer :status
      t.references :medicine_list, index: true, foreign_key: true
      t.references :issuing_agency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
