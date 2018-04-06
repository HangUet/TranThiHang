class AddColumnsToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :fromfinancial, :integer
    add_column :financials, :tofinancial, :integer
    add_column :financials, :status, :integer, default: 1
  end
end
