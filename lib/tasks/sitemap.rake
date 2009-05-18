namespace :fymp do

  desc 'make xml sitemap files'
  task :make_sitemap => :environment do
    ENV['HOST'] ||= 'findyourmp.parliament.uk'
    SiteMap.new(ENV['HOST'], $stdout).write_to_file!
  end

end
