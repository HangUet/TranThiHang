class Api::V1::SituationUsesController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def index
    data = []
    if params[:medicine_name].blank?
      medicine_name = ""
    else
      medicine_name = params[:medicine_name]
    end
    if params[:from_date].present? && params[:to_date].present?
      medicine_lists = MedicineList.where("name like ?", "%#{medicine_name}%")
      medicine_lists.each do |medicine_list|
        medicines = medicine_list.medicines.where(issuing_agency_id: current_user.issuing_agency_id)
                                            .where(origin_medicine_id: nil)
        medicines.each do |medicine|
          inventories = Inventory.where(medicine_id: medicine.id)
                               .where(issuing_agency_id: current_user.issuing_agency_id)
                               .where("DATE(datee) >= ?", params[:from_date].to_date)
                               .where("DATE(datee) <= ?", params[:to_date].to_date)
          if inventories.present?
            inventories.each do |inventory|
              # luong dung thuc te : used, luong dung ly thuyet: inventory.allocate
              loss = 0
              redundancy = 0
              #lượng dùng thực tế = xuất cấp phát - nhập cuối ngày
              used = inventory.export_allocate - inventory.import_end_day
              # x = lượng dùng thực tế - lý thuyết
              x = used - inventory.allocate
              # y = lượng đổ thuốc
              y = inventory.falled
              if x > y
                loss = x
                redundancy = 0
              else
                loss = y
                redundancy = y - x
              end
              inventory.update_attributes loss: loss, redundancy: redundancy
            end
          end
        end

        begin_date = Inventory.where(issuing_agency_id: current_user.issuing_agency_id)
                              .where("DATE(datee) < ?", params[:from_date].to_date)
                              .last
        if begin_date.present?
          begin_date = begin_date.datee.to_date
          data_medicines_begin = medicines.joins(:inventories)
                                  .where(issuing_agency_id: current_user.issuing_agency_id)
                                  .where("datee = ?", begin_date)
                                  .select("source, sum(beginn) as beginn, sum(import) as import,
                                  sum(export) as export, sum(loss) as loss, sum(redundancy) as redundancy,
                                  sum(endd) as endd, medicines.source as source")
                                  .group('medicines.source')

          data_medicines = medicines.joins(:inventories)
                                  .where(issuing_agency_id: current_user.issuing_agency_id)
                                  .where("DATE(datee) >= ?", params[:from_date].to_date)
                                  .where("DATE(datee) <= ?", params[:to_date].to_date)
                                  .select("source, sum(beginn) as beginn, sum(import) as import,
                                  sum(export) as export, sum(loss) as loss, sum(redundancy) as redundancy,
                                  sum(endd) as endd, medicines.source as source")
                                  .group('medicines.source')

          if data_medicines.length > 0
            data_medicines.each do |data_medicine|
              begin_inventory = 0
              data_medicines_begin.each do |beginn|
                if beginn.source == data_medicine.source
                  begin_inventory = beginn.endd
                end
              end
              data.push ({source: data_medicine.source,
                        beginn: begin_inventory,
                        import: data_medicine.import,
                        export: data_medicine.export,
                        loss: data_medicine.loss,
                        redundancy: data_medicine.redundancy,
                        endd: begin_inventory + data_medicine.import - data_medicine.export - data_medicine.loss + data_medicine.redundancy,
                        medicine_name: medicine_list.name,
                        unit: medicine_list.unit,
                        total: begin_inventory + data_medicine.import,
                        composition: medicine_list.composition,
                        concentration: medicine_list.concentration
                      })
            end
          else
            data_medicines_begin.each do |data_medicine|
              data.push ({source: data_medicine.source,
                        beginn: data_medicine.endd,
                        import: 0,
                        export: 0,
                        loss: 0,
                        redundancy: 0,
                        endd: data_medicine.endd,
                        medicine_name: medicine_list.name,
                        unit: medicine_list.unit,
                        total: data_medicine.endd,
                        composition: medicine_list.composition,
                        concentration: medicine_list.concentration,
                      })
            end
          end
        else
          data_medicines = medicines.joins(:inventories)
                                .where(issuing_agency_id: current_user.issuing_agency_id)
                                .where("DATE(datee) >= ?", params[:from_date].to_date)
                                .where("DATE(datee) <= ?", params[:to_date].to_date)
                                .select("source, sum(beginn) as beginn, sum(import) as import,
                                sum(export) as export, sum(loss) as loss, sum(redundancy) as redundancy,
                                sum(endd) as endd")
                                .group('medicines.source')

          data_medicines.each_with_index do |data_medicine, index|
            data.push ({source: data_medicine.source,
                    beginn: 0,
                    import: data_medicine.import,
                    export: data_medicine.export,
                    loss: data_medicine.loss,
                    redundancy: data_medicine.redundancy,
                    endd: data_medicine.import - data_medicine.export - data_medicine.loss + data_medicine.redundancy,
                    medicine_name: medicine_list.name,
                    unit: medicine_list.unit,
                    total: data_medicine.import,
                    composition: medicine_list.composition,
                    concentration: medicine_list.concentration
                  })
          end
        end
      end
      render json: {code: 1, data: data, issuing_agency: current_user.issuing_agency.name}
    else
      render json: {code: 2}
    end
  end
end
