ActionController::Routing::Routes.draw do |map|

  map.resources :constituencies, :has_many => :messages

  # map.connect '/constituencies/:id/mail', :controller => "constituencies", :action => 'mail'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "postcodes"
  map.connect '/postcodes/:postcode.:format', :controller => "postcodes", :action => 'show'
  map.connect '/postcodes/:postcode', :controller => "postcodes", :action => 'show'

  map.connect '/constituencies/hide_members', :controller => "constituencies", :action => 'hide_members'
  map.connect '/constituencies/unhide_members', :controller => "constituencies", :action => 'unhide_members'

  map.connect '/toggle_admin', :controller => "application", :action => 'toggle_admin'
  # See how all your routes lay out with "rake routes"

  map.connect '/admin', :controller => 'admin', :action => 'index'
  map.connect '/admin/', :controller => 'admin', :action => 'sent'

  map.connect '*bad_route', :controller => 'application', :action => 'render_not_found'
end
