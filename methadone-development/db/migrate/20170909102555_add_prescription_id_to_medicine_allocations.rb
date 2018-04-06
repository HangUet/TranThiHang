class AddPrescriptionIdToMedicineAllocations < ActiveRecord::Migration
  def change
    add_reference :medicine_allocations, :prescription, index: true, foreign_key: true
  end
end
