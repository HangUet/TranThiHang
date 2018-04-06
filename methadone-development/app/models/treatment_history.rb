class TreatmentHistory < ActiveRecord::Base
  belongs_to :patient

  scope :in_month, ->month_year, patient_id do
    where("treatment_date LIKE ? and patient_id=?",
      "#{month_year}%", patient_id)
  end

  class << self
    def data_history treatment_histories
      data = []
      day = Time.now.strftime("%d").to_i
      (1..day).each do |i|
        data << {}
      end
      treatment_histories.each do |treatment|
        indexs = treatment.treatment_date.strftime("%d").to_i
        data[indexs - 1] = treatment
      end
      data
    end
  end
end
