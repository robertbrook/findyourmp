ActionController::Routing::Routes.draw do |map|

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "postcodes"
  map.connect ':postcode', :controller => "postcodes", :action => 'constituency'

  # See how all your routes lay out with "rake routes"
end
