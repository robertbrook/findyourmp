require File.expand_path(File.dirname(__FILE__) + '/../data_loader')
require File.expand_path(File.dirname(__FILE__) + '/../commons_member_biographies')
require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')
require File.expand_path(File.dirname(__FILE__) + '/../constituency_upmystreet_links')

namespace :fymp do
  include FindYourMP::DataLoader
  include FindYourMP::CacheWriter

  desc "Populate data for constituencies in DB"
  task :constituencies => :environment do
    load_constituencies
  end

  desc "Populate data for members in DB"
  task :members => :environment do
    file = ENV['file']
    load_members file
  end

  desc "Create cache of all postcode pages"
  task :make_cache => :environment do
    make_cache
  end

  desc "Parse data file for postcode and constituency ID *only*"
  task :parse do
    parse_postcodes
  end

  desc "Populate data for postcode and constituency ID in DB"
  task :populate => :environment do
    load_postcodes
  end

  desc "Populate the postcode districts table"
  task :load_postcode_districts => :environment do
    load_postcode_districts
  end
  
  desc "Populate the upmystreet lookup table"
  task :load_upmystreet_lookup => :environment do
    load_upmystreetcodes
  end
  
end
