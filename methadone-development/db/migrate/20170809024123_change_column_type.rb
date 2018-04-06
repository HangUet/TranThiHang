class ChangeColumnType < ActiveRecord::Migration
  def change
    change_column :medicines, :remaining_number, :float
    change_column :voucher_medicines, :number, :float
    change_column :voucher_medicines, :number, :float
  end
end
