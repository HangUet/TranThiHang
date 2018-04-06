class AddManufacturerToMedicines < ActiveRecord::Migration
  def change
  	add_column :medicines, :provider_id, :integer
  	add_column :medicines, :source, :string
    add_column :medicines, :price, :float
    add_column :medicines, :init_date, :date
  end
end
