class RemoveSomeFieldFromMedicineList < ActiveRecord::Migration
  def change
    remove_column :medicine_lists, :provider, :string
    remove_column :medicine_lists, :source, :string
  end
end
