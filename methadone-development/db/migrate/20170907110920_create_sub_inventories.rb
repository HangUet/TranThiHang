class CreateSubInventories < ActiveRecord::Migration
  def change
    create_table :sub_inventories do |t|
      t.date :datee
      t.integer :beginn, default: 0
      t.integer :import, default: 0
      t.integer :allocate, default: 0
      t.integer :export, default: 0
      t.integer :endd, default: 0
      t.string :batchs
      t.references :issuing_agency, index: true, foreign_key: true
      t.references :medicine, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
