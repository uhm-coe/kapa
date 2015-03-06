Rails.application.routes.draw do

  extra_actions = Proc.new do
    collection do
      get :export
      post :import
    end

    member do
      get :ajax
    end
  end

  namespace :kapa do

    root :to => 'main/base#welcome', :as => :root
    match '/login' => 'main/base#login', :as => :login
    match '/logout' => 'main/base#logout', :as => :logout
    match '/error' => 'main/base#error', :as => :error

    namespace :main do
      get 'persons/lookup(/:id)' => 'persons#lookup', :as => :persons_lookup
      resources :persons, &extra_actions
      resources :contacts, &extra_actions
      resources :curriculums, &extra_actions
      resources :transition_points, &extra_actions
      resources :transition_actions, &extra_actions
      resources :enrollments, &extra_actions
    end

    namespace :artifact do
      resources :documents, &extra_actions
      resources :forms, &extra_actions
      resources :exams, &extra_actions
    end

    namespace :advising do
      resources :sessions, &extra_actions
    end

    namespace :course do
      resources :offers, &extra_actions
      resources :registrations, &extra_actions
    end

    namespace :practicum do
      get 'placements/get_mentor(/:id)' => 'placements#get_mentor', :as => :placements_get_mentor
      get 'placements/update_mentor(/:id)' => 'placements#update_mentor', :as => :placements_update_mentor
      resources :placements, &extra_actions
      resources :sites, &extra_actions
      resources :assignments, &extra_actions
    end

    namespace :report do
      resources :reports, &extra_actions
      resources :datasets, &extra_actions
      get 'datasets/load(/:id)' => 'datasets#load', :as => :datasets_load
      get 'datasets/feed(/:id)' => 'datasets#feed', :as => :datasets_feed
    end

    namespace :admin do
      resources :users, &extra_actions
      resources :terms, &extra_actions
      resources :programs, &extra_actions
      resources :program_offers, &extra_actions
      resources :properties, &extra_actions
      resources :rubrics, &extra_actions
      resources :criterions, &extra_actions
    end

  end

end
