class AddStatusToMedicineList < ActiveRecord::Migration
  def change
    add_column :medicine_lists, :status, :integer, default: 1
  end
end
