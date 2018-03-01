Rails.application.routes.draw do

  extra_actions = Proc.new do
    collection do
      get :export
      post :import
    end
  end

  namespace :kapa do

    root :to => 'user_sessions#show', :as => :root
    get '/logout' => 'user_sessions#destroy', :as => :logout
    get '/error' => 'user_sessions#error', :as => :error
    get '/cas' => 'user_sessions#cas', :as => :cas
    get 'user_session/validate' => 'user_sessions#validate'
    resource :user_session
    get 'persons/lookup(/:id)' => 'persons#lookup', :as => :persons_lookup
    get 'persons/sync(/:id)' => 'persons#sync', :as => :persons_sync
    resources :persons, &extra_actions
    resources :files, &extra_actions
    resources :forms, &extra_actions
    resources :form_templates, &extra_actions
    resources :form_template_fields, &extra_actions
    resources :texts, &extra_actions
    resources :text_templates, &extra_actions
    resources :properties, &extra_actions
    resources :users, &extra_actions
    resources :user_assignments, &extra_actions
  end

end
