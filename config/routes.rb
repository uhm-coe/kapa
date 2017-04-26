Rails.application.routes.draw do

  extra_actions = Proc.new do
    collection do
      get :export
      post :import
    end
  end

  namespace :kapa do

    root :to => 'user_sessions#show', :as => :root
    get '/error' => 'user_sessions#error', :as => :error
    resource :user_session
    get 'persons/lookup(/:id)' => 'persons#lookup', :as => :persons_lookup
    get 'persons/sync(/:id)' => 'persons#sync', :as => :persons_sync
    resources :persons, &extra_actions
    resources :files, &extra_actions
    resources :forms, &extra_actions
    resources :texts, &extra_actions
    resources :text_templates, &extra_actions
    resources :assessment_rubrics, &extra_actions
    resources :assessment_criterions, &extra_actions
    resources :properties, &extra_actions
    resources :reports, &extra_actions
    put 'datasets/load(/:id)' => 'datasets#load_data', :as => :datasets_load
    get 'datasets/feed(/:id)' => 'datasets#feed', :as => :datasets_feed
    resources :users, &extra_actions
    resources :user_assignments, &extra_actions
  end

end
