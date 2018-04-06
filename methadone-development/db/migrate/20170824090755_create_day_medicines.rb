class CreateDayMedicines < ActiveRecord::Migration
  def change
    create_table :day_medicines do |t|
      t.float :remaining
      t.float :booking, default: 0
      t.integer :status
      t.date :init_date
      t.references :sub_medicine, index: true, foreign_key: true
      t.references :sub_voucher, index: true, foreign_key: true
      t.references :issuing_agency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
