require File.expand_path(File.dirname(__FILE__) + '/../data_loader')
require File.expand_path(File.dirname(__FILE__) + '/../commons_member_biographies')
require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')
require File.expand_path(File.dirname(__FILE__) + '/../constituency_upmystreet_links')
require File.expand_path(File.dirname(__FILE__) + '/../boundary_changes')

namespace :fymp do
  include FindYourMP::DataLoader
  include FindYourMP::CacheWriter
  include FindYourMP::BoundaryChanges

  desc "Create new_constituencies file for boundary changes"
  task :create_new_constituencies_file => :environment do
    create_new_constituencies_file
  end

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
  task :parse_postcodes do
    source_file = ENV['source']
    if source_file
      parse_postcodes source_file
    else
      puts 'USAGE: rake fymp:parse_postcodes source=data/NSPDF_MAY_2009_UK_1M_FP.txt'
    end
  end

  desc "Parse data file for postcode and constituency ID *only*"
  task :parse_new_postcodes do
    old_file = ENV['oldfile']
    new_file = ENV['newfile']
    output_file = ENV['output']
    if old_file && new_file
      parse_new_postcodes old_file, new_file, output_file
    else
      puts 'USAGE: rake fymp:parse_new_postcodes oldfile=data/postcodes.txt newfile=data/pcd_pcon_aug_2009_uk_lu/pcd_pcon_aug_2009_uk_lu.txt output=data/new_postcodes.txt'
    end
  end

  desc "Update postcodes from data files for postcode and constituency ID *only*"
  task :diff_postcodes => :environment do
    old_file = ENV['old']
    new_file = ENV['new']
    if old_file && new_file
      diff_postcodes old_file, new_file
    else
      puts 'USAGE: rake fymp:diff_postcodes old=data/NSPDF_FEB_2009_UK_1M.txt new=data/NSPDF_MAY_2009_UK_1M_FP.txt'
    end
  end

  desc "Only analyze potential postcode update and log db discrepancies"
  task :analyze_postcode_update => :environment do
    analyze_postcode_update
  end

  desc "Update postcodes from data files for postcode and constituency ID *only*"
  task :update_postcodes => :environment do
    puts 'USAGE: rake fymp:update_postcodes'
    update_postcodes
  end

  desc "Populate data for postcode and constituency ID in DB"
  task :populate => :environment do
    load_postcodes
  end

  desc "Populate the postcode districts table"
  task :load_postcode_districts => :environment do
    load_postcode_districts
  end

  desc "Populate the manually added postcodes"
  task :load_manual_postcodes => :environment do
    load_manual_postcodes
  end

  desc "Populate the upmystreet lookup table"
  task :load_upmystreet_lookup => :environment do
    load_upmystreetcodes
  end

end
