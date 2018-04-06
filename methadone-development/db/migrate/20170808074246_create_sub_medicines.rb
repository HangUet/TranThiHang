class CreateSubMedicines < ActiveRecord::Migration
  def change
    create_table :sub_medicines do |t|
      t.float :remaining
      t.float :booking, default: 0
      t.integer :status
      t.date :init_date
      t.references :medicine, index: true, foreign_key: true
      t.references :issuing_agency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
