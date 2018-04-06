class CreateDropMedicines < ActiveRecord::Migration
  def change
    create_table :drop_medicines do |t|
      t.references :patient, index: true, foreign_key: true
      t.integer :total, default: 0

      t.timestamps null: false
    end
  end
end
