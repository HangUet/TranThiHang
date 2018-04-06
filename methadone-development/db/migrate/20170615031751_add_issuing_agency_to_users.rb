class AddIssuingAgencyToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :issuing_agency, index: true, foreign_key: true
  end
end
