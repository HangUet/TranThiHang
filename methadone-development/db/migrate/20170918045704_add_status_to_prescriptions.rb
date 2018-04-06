class AddStatusToPrescriptions < ActiveRecord::Migration
  def change
    add_column :prescriptions, :show_status, :integer
  end
end
