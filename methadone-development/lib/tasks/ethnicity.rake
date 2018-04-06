namespace :ethnicity do
  task init: :environment do
    Ethnicity.bulk_insert do |worker|
      ["Kinh","Tày","Thái","Mường","Khơ Me","H'Mông","Nùng","Hoa","Dao","Gia Rai","Ê Đê","Ba Na","Xơ Đăng","Sán Chay","Cơ Ho","Chăm","Sán Dìu","Hrê","Ra Glai","M'Nông","X’Tiêng","Bru-Vân Kiều","Thổ","Khơ Mú","Cơ Tu","Giáy","Giẻ Triêng","Tà Ôi","Mạ","Co","Chơ Ro","Xinh Mun","Hà Nhì","Chu Ru","Lào","Kháng","La Chí","Phú Lá","La Hủ","La Ha","Pà Thẻn","Chứt","Lự","Lô Lô","Mảng","Cờ Lao","Bố Y","Cống","Ngái","Si La","Pu Péo","Rơ măm","Brâu","Ơ Đu"].each do |ethnicity|
        worker.add name: ethnicity
      end
    end
  end
end
