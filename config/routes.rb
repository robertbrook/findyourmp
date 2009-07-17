ActionController::Routing::Routes.draw do |map|

  map.resources :constituencies do |constituency|
    constituency.resources :messages, :only => [:new, :create, :index]
  end
  map.connect '/constituencies/:constituency_id/messages/new', :conditions => { :method => :post }, :controller => 'messages', :action => 'new'

  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.resource :constituency_list

  map.resources :password_resets

  map.root :controller => "postcodes"
  map.connect '/postcodes/:postcode.:format', :controller => "postcodes", :action => 'show'
  map.connect '/postcodes/:postcode', :controller => "postcodes", :action => 'show'
  map.connect '/search/:q.:format', :controller => "search", :action => 'show'
  map.connect '/search/:q', :controller => "search", :action => 'show'
  map.search '/search', :controller => "search", :action => 'index'

  map.connect '/constituencies/hide_members',  :conditions => { :method => :post }, :controller => "constituencies", :action => 'hide_members'
  map.connect '/constituencies/unhide_members',  :conditions => { :method => :post }, :controller => "constituencies", :action => 'unhide_members'

  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.connect '/admin/sent', :controller => 'admin', :action => 'sent'
  map.connect '/admin/sent/:yyyy_mm', :controller => 'admin', :action => 'sent_by_month'
  map.connect '/admin/waiting_to_be_sent', :controller => 'admin', :action => 'waiting_to_be_sent'
  map.connect '/admin/stats', :controller => 'admin', :action => 'stats'
  map.shutdown '/admin/shutdown', :controller => 'admin', :action => 'shutdown'
  map.mailserver_status '/admin/mailserver_status', :controller => 'admin', :action => 'mailserver_status'

  map.api '/api', :controller => 'api', :action => 'index'
  map.connect 'api/search', :controller => 'api', :action => 'search'
  map.connect 'api/postcodes', :controller => 'api', :action => 'postcodes'
  map.connect 'api/constituencies', :controller => 'api', :action => 'constituencies'

  map.connect '/commons/constituency/search/l/:q.html', :controller => 'search', :action => 'redir'
  map.connect '/commons/member/search/l/:q.html', :controller => 'search', :action => 'redir'
  map.connect '/commons/postcode/search/l/:q.html', :controller => 'search', :action => 'redir'

  map.connect '/commons/constituency/cons/l/:up_my_street_code.html', :controller => 'constituencies', :action => 'redir'
  map.connect '/commons/member/cons/l/:up_my_street_code.html', :controller => 'constituencies', :action => 'redir'
  map.connect '/commons/email/l/:up_my_street_code.html', :controller => 'constituencies', :action => 'redir'

  map.connect '/commons/l/', :controller => 'postcodes', :action => 'redir'
  map.connect '/commons/', :controller => 'postcodes', :action => 'redir'

  map.connect '*bad_route', :controller => 'application', :action => 'render_not_found'
end
