class RenamePostcodePrefixesPostcodeDistricts < ActiveRecord::Migration
  def self.up
    remove_index :postcode_prefixes, :name => :index_postcode_prefixes_on_prefix
    rename_table :postcode_prefixes, :postcode_districts

    rename_column :postcode_districts, :prefix, :district
    add_index :postcode_districts, [:district], :name => "index_postcode_districts_on_district", :unique => false
  end

  def self.down
    remove_index :postcode_districts, :name => :index_postcode_districts_on_district

    rename_table :postcode_districts, :postcode_prefixes
    rename_column :postcode_prefixes, :district, :prefix

    add_index :postcode_prefixes, [:prefix], :name => "index_postcode_prefixes_on_prefix", :unique => false
  end
end