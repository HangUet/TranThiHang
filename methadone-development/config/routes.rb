Rails.application.routes.draw do
  root "static_pages#home"
  devise_for :users, :skip => :sessions, :controllers => {:passwords => 'api/v1/users/passwords'}
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post "sign_in", :to => 'sessions#create'
      namespace :users do
        resources :passwords
        resources :registrations
        resources :confirmations
        resources :unlock
        put "update_password", :to => "users#update"
        put "update_name", :to => "users#update_name"
        get "get_prescription_creator", :to => "users#get_prescription_creator"
        get "get_nurse", :to => "users#get_nurse"
        get "get_admin_agency", :to => "users#get_admin_agency"
        get "get_executive_staff", :to => "users#get_executive_staff"
        get "get_list_doctor", :to => "users#get_list_doctor"
        get "get_all_users", :to => "users#get_all_users"
      end

      namespace :admin do
        resources :issuing_agencies
        resources :users
        resources :employments
        resources :educations
        resources :maritals
        resources :financials
        resources :providers
        resources :manufacturers
        resources :sources
        resources :summary_reports, only: :index
        get "/get_all_providers", :to => "providers#get_all"
        get "/get_all_manufacturers", :to => "manufacturers#get_all"
        resources :stop_reasons
        get "/get_all_stop_reasons", :to => "stop_reasons#get_all"
        get "/option_report", :to => "issuing_agencies#option_report"
      end

      namespace :admin_agency do
        resources :users
      end

      namespace :doctors do
        resources :patients, only: [:index]
        post "/search_patient", :to => "patients#search"
        post "/search_and_export", :to => "patients#search_and_export"
        resources :dashboards, only: [:index]
      end

      namespace :nurses do
        resources :vouchers, only: [:index, :update]
        resources :medicine_deliveries, only: :index
        resources :medicine_received, only: [:index, :create]
        resources :nurse_card_stores, only: [:index]
      end

      resources :providers
      resources :manufacturers

      namespace :vouchers do

        namespace :received do
          resources :give_backs, only: [:create, :update]
          resources :import_news, only: [:create, :update]
          resources :end_day, only: [:create, :update]
          resources :accept
          resources :reject
          resources :received_stock_report, only: [:index, :show]
        end

        namespace :delivery do
          resources :cancellations, only: [:create, :update]
          resources :allocations, only: [:create, :update]
          resources :accept
        end

        namespace :received_end_day do
          resources :accept
        end

        post "/search_received_vouchers", to: "received#search_voucher"
        post "/search_delivery_vouchers", to: "delivery#search_voucher"

        resources :received, only: [:index, :show, :update, :destroy]
        resources :delivery, only: [:index, :show, :update, :destroy]
        resources :received_end_day
      end

      namespace :sub_vouchers do

        namespace :delivery do
          resources :allocation
          resources :give_back
          resources :sub_medicines
          resources :accept
        end

        namespace :received do
          resources :end_day
          resources :day_medicines
          resources :accept
        end

        post "/search_delivery_sub_vouchers", to: "delivery#search_sub_voucher"
        post "/search_received_sub_vouchers", to: "received#search_sub_voucher"

        resources :sub_medicines
        resources :delivery
        resources :received
      end
      resources :sub_vouchers

      namespace :sub_medicines do
        resources :delivery
        resources :received
      end
      resources :sub_medicines
      resources :day_medicines
      namespace :store_reports do
        resource :inventories
      end

      namespace :allocations do
        resources :medicines, only: :index
      end

      namespace :selections do
        resources :medicines
      end

      get "/get_lost_medicine", :to => 'report_creators#get_lost_medicine'
      get "/medicine_allocations/get_dosage_patient", :to => 'medicine_allocations#get_dosage_patient'
      get "/patients/get_change_dosage", :to => 'patients#get_change_dosage'
      get "/patients/get_by_barcode", :to => 'patients#get_by_barcode'
      get "/medicine_allocations/get_by_patient", :to => 'medicine_allocations#get_by_patient'
      get "/medicine_allocations/get_by_id", :to => 'medicine_allocations#get_by_id'
      get "/medicine_allocations/get_patient_report/", :to => 'medicine_allocations#get_patient_report'
      get "/daily_import_medicines/import_export_day/", :to => 'daily_import_medicines#import_export_day'
      get "/daily_import_medicines/get_store_report/", :to => 'daily_import_medicines#get_store_report'
      get "/get_falled_history", :to => 'medicine_allocations#get_history_falled'
      resources :avatar_uploaders
      resources :patients
      get "all_report_creator", :to => "report_creators#index"
      post "reports", :to => "report_creators#create"
      post "/search_report", :to => "report_creators#search"
      post "/search_by_nurse/", :to => "patients#search_by_nurse"
      post "/search_and_export_by_nurse", :to => "patients#search_and_export"
      get "/issuing_agencies/get_by_province", :to => 'issuing_agencies#get_by_province'
      resources :issuing_agencies
      resources :ethnicities
      resources :districts
      resources :provinces
      resources :wards
      resources :medicine_types, only: :index
      resources :treatment_histories
      resources :sample_users, only: [:index, :destroy]
      get "/prescriptions/get_last_prescription_of_patient", :to => "prescriptions#get_last_prescription_of_patient"
      resources :prescriptions
      resources :medicine_allocations
      resources :medicines
      resources :medicine_deliveries
      resources :medicine_received
      resources :daily_import_medicines
      resources :daily_export_medicines
      resources :vouchers
      resources :card_stores
      resources :situation_uses
      resources :list_medicines
      put  "/same_patients/:id/feedback", :to => "same_patients#feedback"
      resources :same_patients
      put "notifications/:id/see", :to => "notifications#see"
      resources :notifications
      resources :import_export_medicines, only: :index
      put  "/patient_agency_histories/:id/feedback", :to => "patient_agency_histories#feedback"
      resources :patient_agency_histories
      resources :patient_warnings, only: [:index, :show, :update]
      resources :exports
      resources :prints, only: :index
      resources :stop_treatment_histories
      get "/get_prescription/:id", :to => "prescriptions#getPrescription"
      get "/close_prescription/:id", :to => "prescriptions#closePrescription"

      resources :received_sub_vouchers
      resources :delivery_sub_vouchers
      resources :received_sub_medicines
      resources :delivery_sub_medicines
      get "/filter_prescription", :to => "prescriptions#filter_prescription"
      post "/check_vomited", :to => "prescriptions#check_vomited"
      get "/get_list_patient_revoke", :to => "patients#get_list_patient_revoke"
      get "/get_time_drop_medicine", :to => "patients#get_time_drop_medicine"
      get "/get_loss_reduncy", :to => "card_stores#get_loss_reduncy"
    end
  end
  namespace :admin do
    resources :users, only: [:index, :show, :edit, :update, :destroy]
  end
  get "*path", :to => "static_pages#home"
end
