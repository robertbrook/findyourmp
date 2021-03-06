load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/passenger_mgt.rb')

role :app, domain

namespace :passenger do

  desc "Display the memory stats info"
  task :memory_stats do
    FindYourMP::PassengerManagement.included(self)
    run memory_stats_cmd
  end

  desc "Display detailed status info"
  task :status do
    FindYourMP::PassengerManagement.included(self)
    sudo status_cmd
  end
end