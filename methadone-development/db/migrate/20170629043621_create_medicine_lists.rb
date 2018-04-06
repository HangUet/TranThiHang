class CreateMedicineLists < ActiveRecord::Migration
  def change
    create_table :medicine_lists do |t|
      t.string :name
      t.string :composition
      t.integer :concentration
      t.integer :packing
      t.string :manufacturer
      t.string :provider
      t.string :source

      t.timestamps null: false
    end
  end
end
