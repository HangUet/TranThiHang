namespace :medicine do

  task init: :environment do
    # Medicine.bulk_insert do |worker|
    #   list_issuing_agency = IssuingAgency.all.pluck(:id)
    #   list_issuing_agency.each do |i|
    #     worker.add expiration_date: Time.now + 8.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 1

    #     #het han su dung

    #     worker.add expiration_date: Time.now - 1.days, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 2

    #     worker.add expiration_date: Time.now - 5.days, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 3

    #     worker.add expiration_date: Time.now - 1.days, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 4

    #     worker.add expiration_date: Time.now - 5.days, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 5

    #     #het so luong


    #     worker.add expiration_date: Time.now + 8.months, remaining_number: 0, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 1
    #     worker.add expiration_date: Time.now + 8.months, remaining_number: 0, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 2
    #     worker.add expiration_date: Time.now + 8.months, remaining_number: 0, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 3
    #     worker.add expiration_date: Time.now + 8.months, remaining_number: 0, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 4
    #     worker.add expiration_date: Time.now + 8.months, remaining_number: 0, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 5
    #     #het han thang toi
    #     worker.add expiration_date: Time.now + 1.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 1
    #     worker.add expiration_date: Time.now + 1.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 2
    #     worker.add expiration_date: Time.now + 1.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 3
    #     worker.add expiration_date: Time.now + 1.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 4
    #     worker.add expiration_date: Time.now + 1.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 5
    #     worker.add expiration_date: Time.now + 1.months, remaining_number: 100, production_batch: "1A226", status: 1,
    #       issuing_agency_id: i, medicine_list_id: 1
    #   end
    # end
  end
end
