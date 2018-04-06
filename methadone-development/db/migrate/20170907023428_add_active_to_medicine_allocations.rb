class AddActiveToMedicineAllocations < ActiveRecord::Migration
  def change
    add_column :medicine_allocations, :active, :integer, :default => 1
  end
end
