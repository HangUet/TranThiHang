namespace :category do
  task init: :environment do
    Employment.bulk_insert do |worker|
      ['Trẻ > 6 tuổi đi học, <15 tuổi không đi học', 'Sinh viên, học sinh', 'Hưu và > 60 tuổi', 'Công nhân',
                   'Nông dân', 'Lực lượng vũ trang', 'Trí thức', 'Hành chính, Sự nghiệp', 'Y tế', 'Dịch vụ', 'Việt Kiều', 'Ngoại kiều', 'Khác'].each do |employment|
        worker.add name: employment
      end
    end
    Marital.bulk_insert do |worker|
      ['Chưa lập gia đình', 'Kết hôn', 'Ly hôn', 'Chồng/Vợ đã mất', 'Khác'].each do |marital|
        worker.add name: marital
      end
    end
    Education.bulk_insert do |worker|
      ['Còn nhỏ', 'Mù chữ','Cấp 1/Tiều học', 'Cấp 2/ Trung học cơ sở', 'Cấp 3/Trung học phổ thông', 'Học nghề/Trung học/Cao đẳng/Đại học/…', 'Khác'].each do |education|
        worker.add name: education
      end
    end
    Financial.bulk_insert do |worker|
      ['Nghèo', 'Trung bình', 'Giàu', 'Khác'].each do |financial|
        worker.add name: financial
      end
    end
  end
end
