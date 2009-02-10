ActionController::Routing::Routes.draw do |map|

  map.resources :constituencies, :has_many => :messages

  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session

  map.root :controller => "postcodes"
  map.connect '/postcodes/error.:format', :controller => "postcodes", :action => 'error'
  map.connect '/postcodes/:postcode.:format', :controller => "postcodes", :action => 'show'
  map.connect '/postcodes/:postcode', :controller => "postcodes", :action => 'show'
  map.connect '/search/:search_term.:format', :controller => "postcodes", :action => 'index'
  map.connect '/search/:search_term', :controller => "postcodes", :action => 'index'

  map.connect '/constituencies/:id/:search_term.:format', :controller => "constituencies", :action => 'show'
  map.connect '/constituencies/hide_members', :controller => "constituencies", :action => 'hide_members'
  map.connect '/constituencies/unhide_members', :controller => "constituencies", :action => 'unhide_members'

  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.connect '/admin/sent', :controller => 'admin', :action => 'sent'
  map.connect '/admin/draft', :controller => 'admin', :action => 'draft'
  map.connect '/admin/attempted_send', :controller => 'admin', :action => 'attempted_send'

  map.connect '*bad_route', :controller => 'application', :action => 'render_not_found'
end
