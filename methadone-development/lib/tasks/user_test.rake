namespace :user_test do
  desc "Task description"
  task init: :environment do
    list_id = IssuingAgency.all.pluck(:id)
    roles = ['admin', 'admin_agency', 'doctor', 'storekeeper', 'executive_staff', 'nurse']

    roles.each do |role|
      User.create(first_name: Faker::Name.last_name,
        last_name: Faker::Name.last_name,
        username: "#{role}",
        email: "#{role}@gmail.com",
        password: "Methadone@2017",
        password_confirmation: "Methadone@2017",
        role: role, issuing_agency_id: list_id[0])
    end


    list_id.each_with_index do |issuing_agency_id, index|
      roles.each do |role|
        User.create(first_name: Faker::Name.last_name,
          last_name: Faker::Name.last_name,
          username: "#{role}_#{index + 1}",
          email: "#{role}_#{index + 1}@gmail.com",
          password: "Methadone@2017",
          password_confirmation: "Methadone@2017",
          role: role, issuing_agency_id: issuing_agency_id)
      end
    end
  end
end
