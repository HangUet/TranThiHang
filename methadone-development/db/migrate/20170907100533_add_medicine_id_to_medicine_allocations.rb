class AddMedicineIdToMedicineAllocations < ActiveRecord::Migration
  def change
    add_reference :medicine_allocations, :medicine, index: true, foreign_key: true
  end
end
