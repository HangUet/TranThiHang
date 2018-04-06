namespace :prescription_expire_check do
  task init: :environment do
    patients = Patient.all
    today = Date.today
    patients.each do |patient|
      @prescriptions = Prescription.open.where(patient: patient.id)
      if @prescriptions.present?
        @prescriptions = @prescriptions.where("DATE(begin_date) <= ?", today)
                                      .where('DATE(end_date) >= ?', today)
        if @prescriptions.present?
          @prescriptions.each do |prescription|
            if prescription.end_date_expected.day == (today + 3.days).day || prescription.end_date.day == (today + 3.days).day ||
              prescription.end_date_expected.day == (today + 1.days).day || prescription.end_date.day == (today + 1.days).day
              notification = Notification.new url: "#", user_id: prescription.user_id, content: "Bệnh nhân #{patient.name} sắp hết hạn đơn thuốc"
              if notification.save
                notification.update_attributes(url: "main/notify_prescription/#{notification.id}?" + "patient_id=" + patient.id.to_s + "&notify_status=warning_for_medication")
              end
            end
          end
        end                          
      end
    end
  end
end
