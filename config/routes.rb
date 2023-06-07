Rails.application.routes.draw do
  resources :sc_backends do
    member do
      post 'change_status'
    end
  end
  
  resources :sc_jobs, except: :index do
    collection do
      get :index
      put :index
    end
    member do
      put :run
      put :pause
    end
  end

  resources :console_dbs do 
    collection do 
      get 'db_list'
      get 'fault_code_master'
      get 'fault_code_cust_stats'
    end
  end


  resources :esb_configs
  
  resources :sc_backend_response_codes, except: :index do
    collection do
      get :index
      put :index
    end
  end
  
  resources :sc_fault_codes do
     member do
      get 'audit_logs'
      put 'approve'
    end
  end

  
  resources :sc_backend_settings, except: :index do
    collection do
      get :index
      put :index
      get :get_service_codes
      get :settings
    end
    member do
      get 'audit_logs'
      put 'approve'
    end
  end
  
  resources :sc_proxies do
    member do
      get :audit_logs
      put :approve
    end
  end
  
  resources :sc_services do
    member do
      get :audit_logs
      put :approve
    end
    collection do
      put :index
    end
  end

  get '/sc_backend_response_codes/:id/audit_logs' => 'sc_backend_response_codes#audit_logs'
  put '/sc_backend_response_codes/:id/approve' => "sc_backend_response_codes#approve"
  put '/sc_backend/:id/approve' => "sc_backends#approve"
  get '/sc_backend/:id/previous_status_changes' => 'sc_backends#previous_status_changes', as: :previous_status_changes
  get '/sc_backend/:id/audit_logs' => 'sc_backends#audit_logs'
end
