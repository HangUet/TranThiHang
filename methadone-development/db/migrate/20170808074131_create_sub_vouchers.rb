class CreateSubVouchers < ActiveRecord::Migration
  def change
    create_table :sub_vouchers do |t|
      t.integer :status
      t.integer :typee
      t.datetime :datee
      t.references :issuing_agency, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :sender
      t.string :receiver
      t.string :agency_receiver
      t.string :code
      t.string :invoice_number
      t.string :receipt_number
      t.integer :voucher_id

      t.timestamps null: false
    end
  end
end
