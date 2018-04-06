class CreatePatientContacts < ActiveRecord::Migration
  def change
    create_table :patient_contacts do |t|
      t.integer :contact_type
      t.string :name
      t.string :address
      t.string :telephone
      t.references :patient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
