class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|

    	t.date :datee
      t.decimal :beginn, default: 0, precision: 8, scale: 2
      t.decimal :import, default: 0, precision: 8, scale: 2
      t.decimal :export, default: 0, precision: 8, scale: 2
      t.decimal :endd, default: 0, precision: 8, scale: 2
      t.decimal :loss, default: 0, precision: 8, scale: 2
      t.decimal :redundancy, default: 0, precision: 8, scale: 2
      t.decimal :import_end_day, default: 0, precision: 8, scale: 2
      t.decimal :export_allocate, default: 0, precision: 8, scale: 2
      t.decimal :allocate, default: 0, precision: 8, scale: 2
      t.decimal :falled, default: 0, precision: 8, scale: 2

      t.references :issuing_agency, index: true, foreign_key: true
      t.references :medicine, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
