Kapa::Application.routes.draw do

  root :to => 'main/base#index'
  match '/login' => 'main/base#login', :as => :login
  match '/logout' => 'main/base#logout', :as => :logout
  match '/error' => 'main/base#error', :as => :error

  namespace :main do
      match 'persons/:action(/:id)' => 'persons', :as => :persons
      match 'contacts/:action(/:id)' => 'contacts', :as => :contacts
      match 'curriculums/:action(/:id)' => 'curriculums', :as => :curriculums
      match 'transition_points/:action(/:id)' => 'transition_points', :as => :transition_points
      match 'transition_actions/:action(/:id)' => 'transition_actions', :as => :transition_actions
  end

  namespace :artifact do
      match 'documents/:action(/:id)' => 'documents', :as => :documents
      match 'forms/:action(/:id)' => 'forms', :as => :forms
      match 'exams/:action(/:id)' => 'exams', :as => :exams
  end

  namespace :advising do
      match 'sessions/:action(/:id)' => 'sessions', :as => :sessions
  end

  namespace :course do
      match 'rosters/:action(/:id)' => 'rosters', :as => :rosters
      match 'registrations/:action(/:id)' => 'registrations', :as => :registrations
  end

  namespace :practicum do
      match 'profiles/:action(/:id)' => 'profiles', :as => :profiles
      match 'placements/:action(/:id)' => 'placements', :as => :placements
      match 'schools/:action(/:id)' => 'schools', :as => :schools
      match 'assignments/:action(/:id)' => 'assignments', :as => :assignments
  end

  namespace :admin do
      match 'users/:action(/:id)' => 'users', :as => :users
      match 'programs/:action(/:id)' => 'programs', :as => :programs
      match 'program_offers/:action(/:id)' => 'program_offers', :as => :program_offers
      match 'properties/:action(/:id)' => 'properties', :as => :properties
      match 'restricted_reports/:action(/:id)' => 'restricted_reports', :as => :restricted_reports
      match 'rubrics/:action(/:id)' => 'rubrics', :as => :rubrics
      match 'criterions/:action(/:id)' => 'criterions', :as => :criterions
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
end
