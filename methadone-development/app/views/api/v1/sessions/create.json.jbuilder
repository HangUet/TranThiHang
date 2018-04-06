json.code 1
json.message t("common.success")
json.token @auth_token
json.user do
  json.extract! @user, :id, :email, :username, :role, :last_name, :first_name, :issuing_agency_id
  json.agency @user.issuing_agency
  json.full_name "#{@user.first_name} #{@user.last_name}" rescue nil
  json.agency_address "#{@user.issuing_agency.address}, #{@user.issuing_agency.ward.name},
    #{@user.issuing_agency.district.name} , #{@user.issuing_agency.province.name}"
end
