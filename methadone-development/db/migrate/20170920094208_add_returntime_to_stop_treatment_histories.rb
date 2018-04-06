class AddReturntimeToStopTreatmentHistories < ActiveRecord::Migration
  def change
    add_column :stop_treatment_histories, :return_time, :date
  end
end
