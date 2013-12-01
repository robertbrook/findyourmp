# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
require "./config/environment.rb"
require 'cucumber/rails/world'
# require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support
# Cucumber::Rails.use_transactional_fixtures

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end


module NavigationHelpers
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      root_path
    
    # Add more page name => path mappings here
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
