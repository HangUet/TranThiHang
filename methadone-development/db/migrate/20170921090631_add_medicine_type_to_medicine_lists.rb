class AddMedicineTypeToMedicineLists < ActiveRecord::Migration
  def change
    add_reference :medicine_lists, :medicine_type, index: true, foreign_key: true
  end
end
