class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.integer :status, default: 1

      t.timestamps null: false
    end
  end
end
