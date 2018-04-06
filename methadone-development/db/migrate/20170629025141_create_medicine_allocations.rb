class CreateMedicineAllocations < ActiveRecord::Migration
  def change
    create_table :medicine_allocations do |t|
      t.datetime :allocation_date
      t.float :dosage
      t.integer :status
      t.integer :typee
      t.integer :notify_status, default: 0
      t.integer :vomited_allocation, default: 0

      t.references :user, index: true, foreign_key: true
      t.references :patient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
