class CreateIssuingAgencies < ActiveRecord::Migration
  def change
    create_table :issuing_agencies do |t|
      t.string :name
      t.string :code
      t.string :address
      t.references :province, index: true, foreign_key: true
      t.references :district, index: true, foreign_key: true
      t.references :ward, index: true, foreign_key: true
    end
  end
end
