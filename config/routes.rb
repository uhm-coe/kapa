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
    resources :curriculums, &extra_actions
    resources :transition_points, &extra_actions
    resources :transition_actions
    resources :enrollments, &extra_actions
    resources :files, &extra_actions
    resources :forms, &extra_actions
    resources :texts, &extra_actions
    resources :text_templates, &extra_actions
    resources :exams, &extra_actions
    resources :reports, &extra_actions
    resources :advising_sessions, &extra_actions
    resources :courses, &extra_actions
    resources :course_registrations, &extra_actions
    get 'practicum_placements/get_mentor(/:id)' => 'practicum_placements#get_mentor', :as => :practicum_placements_get_mentor
    put 'practicum_placements/update_mentor(/:id)' => 'practicum_placements#update_mentor', :as => :practicum_placements_update_mentor
    resources :practicum_placements, &extra_actions
    resources :practicum_logs, &extra_actions
    resources :practicum_sites, &extra_actions
    resources :users, &extra_actions
    resources :user_assignments, &extra_actions
    resources :terms, &extra_actions
    resources :programs, &extra_actions
    resources :program_offers
    resources :properties, &extra_actions
    resources :assessment_rubrics, &extra_actions
    resources :assessment_criterions, &extra_actions
    resources :datasets, &extra_actions
    put 'datasets/load(/:id)' => 'datasets#load_data', :as => :datasets_load
    get 'datasets/feed(/:id)' => 'datasets#feed', :as => :datasets_feed
  end

end
