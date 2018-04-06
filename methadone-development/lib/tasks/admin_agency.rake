namespace :admin_agency do
  task init: :environment do
    users = []
    File.open("#{Rails.root}/lib/tasks/admin_agency.csv").each_line do |line|
      users.push line.gsub("\n", "").split("|")
    end
    users.shift
    users.each do |user|
      User.create(first_name: user[0],
          last_name: user[1],
          username: user[2],
          email: user[3],
          password: user[4],
          password_confirmation: user[4],
          role: 1, issuing_agency_id: user[5])
    end
    User.create(first_name: "ten_tam",
          last_name: "ten_tam",
          username: "Quản trị hệ thống",
          email: "methadone@vaac.gov.vn",
          password: "5148ulgu&&^&$",
          password_confirmation: "5148ulgu&&^&$",
          role: 0, issuing_agency_id: 1)

  end
  def random_password
    list_number = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    list_char = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a",
      "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m"]
    list_special = ["!", "@", "#", "$", "%", "^", "&", "*"]
    num_pass = [*9..15].sample
    num_number = [*3..4].sample
    num_char = [*3..4].sample
    num_special = num_pass - num_number - num_char
    pass = []
    num_number.times do
      pass << list_number[[*0..9].sample]
    end
    num_char.times.each do
      pass << list_char[[*0..25].sample]
    end
    num_special.times do
      pass << list_special[[*0..7].sample]
    end
    pass.shuffle
    final_pass = ""
    pass.each do |pa|
      final_pass = final_pass + pa
    end
    return final_pass
  end
end
