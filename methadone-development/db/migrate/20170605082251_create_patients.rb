class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|

      t.string :name,   null: false, default: ""
      t.string :gender
      t.datetime :birthdate
      t.string :jobs
      t.references :ethnicity, index: true, foreign_key: true
      t.string :avatar

      t.references :province, index: true, foreign_key: true
      t.references :district, index: true, foreign_key: true
      t.references :ward, index: true, foreign_key: true
      t.string :hamlet
      t.string :address
      t.integer :resident_province_id
      t.integer :resident_district_id
      t.integer :resident_ward_id
      t.string :resident_hamlet
      t.string :resident_address
      t.string :mobile_phone

      t.string :marital_status
      t.integer :no_of_children
      t.string :education_level
      t.string :financial_status

      t.datetime :admission_date

      t.string :referral_agency

      t.string :card_number
      t.datetime :issued_date
      t.references :issuing_agency, index: true, foreign_key: true

      t.integer :identification_type
      t.string :identification_number
      t.datetime :identification_issued_date
      t.string :identification_issued_by

      t.string :health_insurance_code
      t.integer :active, default: 1

      t.timestamps null: false
    end
  end
end
