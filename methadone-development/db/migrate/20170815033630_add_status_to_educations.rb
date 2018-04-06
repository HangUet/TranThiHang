class AddStatusToEducations < ActiveRecord::Migration
  def change
    add_column :educations, :status, :integer, default: 1
  end
end
