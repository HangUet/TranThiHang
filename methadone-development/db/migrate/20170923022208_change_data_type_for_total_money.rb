class ChangeDataTypeForTotalMoney < ActiveRecord::Migration
  def self.up
    change_table :vouchers do |t|
      t.change :total_money, :decimal, :precision => 14, :scale => 2
    end
  end
  def self.down
    change_table :vouchers do |t|
      t.change :total_money, :float
    end
  end
end
