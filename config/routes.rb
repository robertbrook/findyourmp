ActionController::Routing::Routes.draw do |map|

  map.resources :constituencies, :has_one => :member

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "postcodes"
  map.connect '/postcodes/:postcode.:format', :controller => "postcodes", :action => 'show'
  map.connect '/postcodes/:postcode', :controller => "postcodes", :action => 'show'

  map.connect '/toggle_admin', :controller => "application", :action => 'toggle_admin'
  # See how all your routes lay out with "rake routes"
end
