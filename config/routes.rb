FindYourMP::Application.routes.draw do
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
  
  resources :constituencies
  
  match '/constituencies/hide_members' => 'constituencies#hide_members', :via => :post
  match '/constituencies/unhide_members' => 'constituencies#unhide_members', :via => :post
  
  resource :account, :controller => "users"
  resources :users
  resource :user_session
  resource :constituency_list
  
  resources :password_resets
  
  root :to => 'postcodes#index'
  
  match '/postcodes/:postcode' => 'postcodes#show'
  match '/search/:q' => 'search#show'
  match '/search' => 'search#index', :as => "search"
  
  match '/admin' => 'admin#index', :as => "admin"
  match '/admin/sent'  => 'admin#sent'
  match '/admin/sent/:yyyy_mm' => 'admin#sent_by_month'
  match '/admin/waiting_to_be_sent' => 'admin#waiting_to_be_sent'
  match '/admin/stats' => 'admin#stats'
  match '/admin/shutdown' => 'admin#shutdown', :as => "shutdown"
  match '/admin/mailserver_status' => 'admin#mailserver_status', :as => "mailserver_status"
  
  match '/admin/blacklist' => 'blacklisted_postcodes#index', :as => "blacklisted_postcodes"
  match '/admin/blacklist/restore/:code' => 'blacklisted_postcodes#restore'
  match '/admin/blacklist/new' => 'blacklisted_postcodes#new'
  
  match '/admin/manual_postcodes' => 'manual_postcodes#index', :as => "manual_postcodes"
  match '/admin/manual_postcodes/remove/:code' => 'manual_postcodes#remove'
  match '/admin/manual_postcodes/new' => 'manual_postcodes#new'
  
  match '/api' => 'api#index', :as => "api"
  match '/api/search' => 'api#search'
  match '/api/postcodes' => 'api#postcodes'
  match '/api/constituencies' => 'api#constituencies'
  
  match '/commons/constituency/search/l/:q.html' => 'search#redir'
  match '/commons/member/search/l/:q.html' => 'search#redir'
  match '/commons/postcode/search/l/:q.html' => 'search#redir'
  
  match '/commons/constituency/cons/l/:up_my_street_code.html' => 'constituencies#redir'
  match '/commons/member/cons/l/:up_my_street_code.html' => 'constituencies#redir'
  match '/commons/email/l/:up_my_street_code.html' => 'constituencies#redir'
  
  match '/commons/l/' => 'postcodes#redir'
  match '/commons/' => 'postcodes#redir'
  
  match '*bad_route' => 'application#render_not_found', :as => "bad_route"
  
  
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
