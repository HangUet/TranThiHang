namespace :user do
  task init: :environment do
    list_id = IssuingAgency.all.pluck(:id)
    roles = ['nurse']


    list_id.each_with_index do |issuing_agency_id, index|
      roles.each do |role|
        User.create(first_name: Faker::Name.last_name,
          last_name: Faker::Name.last_name,
          username: "#{role}_#{index + 1}",
          email: "#{role}_#{index + 1}@gmail.com",
          password: "Qqqqqq@2",
          password_confirmation: "Qqqqqq@2",
          role: role, issuing_agency_id: issuing_agency_id)
      end
    end
  end
end
