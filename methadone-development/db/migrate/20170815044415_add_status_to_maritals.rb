class AddStatusToMaritals < ActiveRecord::Migration
  def change
    add_column :maritals, :status, :integer, default: 1
  end
end
