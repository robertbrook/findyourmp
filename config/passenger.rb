load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/passenger.rb')

role :app, domain

namespace :passenger do
  desc "Display the memory stats info"
  task :memory_stats do
    run FindYourMP::Passenger.memory_stats_cmd
  end

  desc "Display detailed status info"
  task :status do
    sudo FindYourMP::Passenger.status_cmd
  end
end