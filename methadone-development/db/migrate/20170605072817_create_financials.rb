class CreateFinancials < ActiveRecord::Migration
  def change
    create_table :financials do |t|
      t.string :name
    end
  end
end
