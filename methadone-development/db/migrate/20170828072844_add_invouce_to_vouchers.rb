class AddInvouceToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :invoice_number, :string
    add_column :vouchers, :code, :string
    add_column :vouchers, :total_money, :float
    add_column :vouchers, :division, :integer
    add_reference :vouchers, :user, index: true, foreign_key: true
  end
end
