class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.integer :status
      t.integer :typee
      t.datetime :datee
      t.references :issuing_agency, index: true, foreign_key: true
      t.string :sender
      t.string :receiver
      t.string :agency_sender_receiver

      t.timestamps null: false
    end
  end
end
