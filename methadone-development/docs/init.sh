bundle install
rake db:migrate:reset
rake address:init
rake issuing_agency:init
rake ethnicity:init
# rake patient:init
# rake patient_contacts:init
# rake user:init
# rake prescription:init
# rake dashboard_data:init
rake user:init
rake import_patient_all:init
rake import_patient_tay_ho:init
rake import_patient_lb:init
rake import_patient_pk:init
rake import_patient_dongda:init
rake admin_agency:init
rake medicine_list:init
# rake medicine:init
rake total_in_stock:init
rake category:init
rake change_agency_temporary:init
