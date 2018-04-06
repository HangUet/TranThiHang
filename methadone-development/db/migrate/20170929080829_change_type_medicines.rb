class ChangeTypeMedicines < ActiveRecord::Migration
  def change
    change_column :medicines, :remaining_number, :decimal, :precision => 10, :scale => 2
    change_column :medicines, :booking, :decimal, :precision => 10, :scale => 2
  end
end
