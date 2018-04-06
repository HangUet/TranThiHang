class AddMedicineListIdToPrescriptions < ActiveRecord::Migration
  def change
    add_reference :prescriptions, :medicine_list, index: true, foreign_key: true
  end
end
