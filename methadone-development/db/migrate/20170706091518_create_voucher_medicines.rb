class CreateVoucherMedicines < ActiveRecord::Migration
  def change
    create_table :voucher_medicines do |t|
      t.references :medicine, index: true, foreign_key: true
      t.references :voucher, index: true, foreign_key: true
      t.integer :number
      t.timestamps null: false
    end
  end
end
