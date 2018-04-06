class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string  :name
      t.integer :status, default: 1
    end
  end
end
