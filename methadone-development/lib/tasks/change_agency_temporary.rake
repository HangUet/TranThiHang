namespace :change_agency_temporary do
  task init: :environment do
    User.doctor.each do |user|
      @patient_agency_history = PatientAgencyHistory.accepted.where.not(end_date: nil)
      .where(receiver_agency_id: user.issuing_agency_id)
      receiver_doctors = User.doctor.where(issuing_agency_id: user.issuing_agency_id)
      @patient_agency_history.each do |patient|
        if (Date.today - patient.end_date.to_date).to_i < 5
          if patient.status != "expiration_soon"
            patient.assign_attributes(status: :expiration_soon)
            patient.save
            Notification.bulk_insert(ignore: true) do |worker|
              receiver_doctors.each do |doctor|
                worker.add({content: "Yêu cầu chuyển cơ sở tạm thời của bệnh nhân #{patient.patient.name}
                  sắp hết hạn", url: "main/patient_agency_histories/#{patient.id}",
                  user_id: doctor.id})
              end
            end
          end
        end
      end
    end
  end
end
