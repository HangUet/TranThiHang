class CreateMedicineSources < ActiveRecord::Migration
  def change
    create_table :medicine_sources do |t|
      t.string :name
      t.integer :status, default: 1

      t.timestamps null: false
    end
  end
end
