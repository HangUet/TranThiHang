class AddBookingToMedicines < ActiveRecord::Migration
  def change
    add_column :medicines, :booking, :float, default: 0
    add_column :medicines, :division, :integer
    add_column :medicines, :origin_medicine_id, :integer
  end
end
