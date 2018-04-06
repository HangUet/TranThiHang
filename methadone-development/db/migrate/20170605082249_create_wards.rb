class CreateWards < ActiveRecord::Migration
  def change
    create_table :wards do |t|
      t.string :name

      t.string :typee
      t.references :district, index: true, foreign_key: true
    end
  end
end
