namespace :fymp do

  desc 'make xml sitemap files'
  task :make_sitemap => :environment do
    unless ENV['HOST']
      puts ''
      puts 'usage: rake hansard:make_sitemap HOST=hostname'
      puts ''
      exit 0
    end
    SiteMap.new(ENV['HOST'], $stdout).write_to_file!
  end

end
