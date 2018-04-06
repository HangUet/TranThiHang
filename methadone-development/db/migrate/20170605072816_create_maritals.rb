class CreateMaritals < ActiveRecord::Migration
  def change
    create_table :maritals do |t|
      t.string :name
    end
  end
end
