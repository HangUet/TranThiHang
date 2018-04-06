class AddStatusToEmployments < ActiveRecord::Migration
  def change
    add_column :employments, :status, :integer, default: 1
  end
end
