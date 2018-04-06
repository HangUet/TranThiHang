class CreateSubVoucherSubMedicines < ActiveRecord::Migration
  def change
    create_table :sub_voucher_sub_medicines do |t|

      t.references :sub_medicine, index: true, foreign_key: true
      t.references :sub_voucher, index: true, foreign_key: true
      t.integer :day_medicine_id
      t.float :number

      t.timestamps null: false
    end
  end
end
