require File.expand_path(File.dirname(__FILE__) + '/../data_loader')
require File.expand_path(File.dirname(__FILE__) + '/../member_bios')
require File.expand_path(File.dirname(__FILE__) + '/../commons_member_bios')
require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')

namespace :fymp do

  include FindYourMP::DataLoader
  include FindYourMP::CacheWriter

  desc "Populate data for constituencies in DB"
  task :constituencies => :environment do
    load_constituencies
  end

  desc "Populate data for members in DB"
  task :members => :environment do
    load_members
    CommonsMemberBios.load_bios 'http://www.parliament.uk/directories/hciolists/alms.cfm'
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

end
