namespace :fymp do
  namespace :cache do
    desc "Expire page cache"
    task :expire_pages => :environment do
      SiteSweeper.sweep
    end
  end
end