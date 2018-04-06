class AddUnitToMedicineLists < ActiveRecord::Migration
  def change
    add_column :medicine_lists, :unit, :string, default: "ml"
  end
end
