Rails.application.routes.draw do

  concern :extra_actions do
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
    resources :persons, :concerns => :extra_actions
    resources :curriculums, :concerns => :extra_actions
    resources :transition_points, :concerns => :extra_actions
    resources :transition_actions
    resources :enrollments, :concerns => :extra_actions
    resources :files, :concerns => :extra_actions
    resources :forms, :concerns => :extra_actions
    resources :notifications, :concerns => :extra_actions
    get 'notifications/dismiss(/:id)' => 'notifications#dismiss', :as => :notifications_dismiss
    resources :texts, :concerns => :extra_actions
    resources :text_templates, :concerns => :extra_actions
    resources :exams, :concerns => :extra_actions
    resources :reports, :concerns => :extra_actions
    resources :advising_sessions, :concerns => :extra_actions
    resources :courses, :concerns => :extra_actions
    resources :course_registrations, :concerns => :extra_actions
    get 'practicum_placements/get_mentor(/:id)' => 'practicum_placements#get_mentor', :as => :practicum_placements_get_mentor
    put 'practicum_placements/update_mentor(/:id)' => 'practicum_placements#update_mentor', :as => :practicum_placements_update_mentor
    resources :practicum_placements, :concerns => :extra_actions
    resources :practicum_logs, :concerns => :extra_actions
    resources :practicum_sites, :concerns => :extra_actions
    resources :users, :concerns => :extra_actions
    resources :user_assignments, :concerns => :extra_actions
    resources :terms, :concerns => :extra_actions
    resources :programs, :concerns => :extra_actions
    resources :program_offers
    resources :properties, :concerns => :extra_actions
    resources :assessment_rubrics, :concerns => :extra_actions
    resources :assessment_criterions, :concerns => :extra_actions
    resources :datasets, :concerns => :extra_actions
    put 'datasets/load(/:id)' => 'datasets#load_data', :as => :datasets_load
    get 'datasets/feed(/:id)' => 'datasets#feed', :as => :datasets_feed
  end

end
