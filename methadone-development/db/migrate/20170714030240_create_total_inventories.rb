class CreateTotalInventories < ActiveRecord::Migration
  def change
    create_table :total_inventories do |t|
      t.datetime :save_date
      t.integer :total
      t.integer :expire_next_month
      t.string :source

      t.timestamps null: false
    end
  end
end
