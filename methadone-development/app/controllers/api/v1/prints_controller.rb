class Api::V1::PrintsController < ApplicationController
  before_action :authenticate_request!
  skip_before_filter  :verify_authenticity_token

  respond_to :json
  def index
    @issuing_agency = @current_user.issuing_agency
    @ward = @issuing_agency.ward.name
    @district = @issuing_agency.district.name
    @province = @issuing_agency.province.name
    @prescription = Prescription.find_by id:params[:id]
    @doctor_name = @prescription.user.first_name + " " + @prescription.user.last_name
    @patient = @prescription.patient
    @text = convert(@prescription.dosage)
    @checkmale = @patient.gender == "male" ? true : false
    @checkfemale = @patient.gender == "female" ? true : false
    @begin_date = @prescription.begin_date.strftime "%d/%m/%Y"
    @end_date = @prescription.end_date.strftime "%d/%m/%Y"
    @date = @prescription.created_at.strftime "%d/%m/%Y"
    @household_address = @prescription.patient.address
    @household_hamlet = @prescription.patient.hamlet
    @household_ward = @prescription.patient.ward.name
    @household_district = @prescription.patient.district.name
    @household_province = @prescription.patient.province.name
    @medicine_name = "#{@prescription.medicine_list.name} (#{@prescription.medicine_list.composition})" rescue nil
    render json: {issuing_agency: @issuing_agency, prescription: @prescription,
      ward: @ward, district: @district, province: @province, patient: @patient,
      text: @text, checkmale: @checkmale, checkfemale: @checkfemale,
      doctor_name: @doctor_name, begin_date: @begin_date, end_date: @end_date, date: @date,
      household_address: @household_address, household_hamlet: @household_hamlet,
      household_ward: @household_ward, household_district: @household_district,
      household_province: @household_province, medicine_name: @medicine_name, code: 1}
  end
  private

  def convert(dosage)
    hangdonvi = dosage % 10
    hangchuc = ((dosage % 100) - hangdonvi)/ 10
    hangtram = ((dosage % 1000) - (dosage % 100))/ 100
    hangnghin = ((dosage % 10000) - (dosage % 1000))/1000
    char1 = ["không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"]
    char2 = ["", "mốt", "hai", "ba", "bốn", "lăm", "sáu", "bảy", "tám", "chín"]
    h1 = []
    hdv = []
    10.times do |i|
      h1[i] = char1[i]
      hdv[i] = char2[i]
    end
    if hangnghin != 0
      return doc1so(h1, hangnghin) + " nghìn " + doc3so(hangdonvi, hangchuc, hangtram, hangnghin, h1, hdv)
    else
      return doc3so(hangdonvi, hangchuc, hangtram, hangnghin, h1, hdv)
    end
  end
  def doc3so(hangdonvi, hangchuc, hangtram, hangnghin, h1, hdv)
    if(checkzero(hangdonvi, hangchuc, hangtram) == 0)
      if (hangnghin == 0)
        return docdonvi(hdv, h1, hangdonvi, hangchuc)
      else
        return "không trăm linh " + docdonvi(hdv, h1, hangdonvi, hangchuc)
      end
    else
      if(checkzero(hangdonvi, hangchuc, hangtram) == 1)
        return doc1so(h1, hangtram) + " trăm"
      else
        if(checkzero(hangdonvi, hangchuc, hangtram) == 2)
          return ""
        else
          if(hangtram == 0)
            if(hangnghin == 0)
              if(hangchuc == 1)
                if(hangdonvi != 1)
                  return " mười " + docdonvi(hdv, h1, hangdonvi, hangchuc)
                else
                  return " mười một "
                end
              else
                if(hangchuc == 0)
                  return " linh " + docdonvi(hdv, h1, hangdonvi, hangchuc)
                else
                  return doc1so(h1, hangchuc) + " mươi " + docdonvi(hdv, h1, hangdonvi, hangchuc)
                end
              end
            else
              if(hangchuc == 1)
                if(hangdonvi != 1)
                  return "mười " + docdonvi(hdv, h1, hangdonvi, hangchuc)
                else
                  return "mười một "
                end
              else
                if(hangchuc == 0)
                  return "không trăm linh " + docdonvi(hdv, h1, hangdonvi, hangchuc)
                else
                  return "không trăm " + doc1so(h1, hangchuc) + " mươi " + docdonvi(hdv, h1, hangdonvi, hangchuc)
                end
              end
            end
          else
            if(hangchuc == 0)
              return doc1so(h1, hangtram) + " trăm linh " + docdonvi(hdv, h1, hangdonvi, hangchuc)
            else
              if(hangchuc == 1)
                return doc1so(h1, hangtram) + " trăm mười một"
              else
                return doc1so(h1, hangtram) + " trăm " + doc1so(h1, hangchuc) + " mươi " + docdonvi(hdv, h1, hangdonvi, hangchuc)
              end
            end
          end
        end
      end
    end
  end
  def docdonvi(hdv, h1, hangdonvi, hangchuc)
    if(hangchuc != 0)
      return hdv[hangdonvi]
    else
      return h1[hangdonvi]
    end
  end

  def doc1so(h1, number)
    return h1[number]
  end

  def checkzero(hangdonvi, hangchuc, hangtram)
    if hangtram == hangchuc && hangtram == 0 && hangdonvi != 0
      return 0
    elsif hangchuc == hangdonvi && hangchuc == 0 && hangtram != 0
      return 1
    elsif hangtram == hangchuc && hangchuc == hangdonvi && hangtram == 0
      return 2
    else
      return 3
    end
  end
end
