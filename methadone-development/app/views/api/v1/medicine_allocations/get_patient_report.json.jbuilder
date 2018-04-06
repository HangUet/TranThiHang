json.code 1
json.message t("common.success")
json.data do
  json.male_give_up            @male_give_up
  json.female_give_up          @female_give_up
  json.male_turn_give_up       @male_turn_give_up
  json.female_turn_give_up     @female_turn_give_up
  json.issuing_agency_name     @issuing_agency_name
end
