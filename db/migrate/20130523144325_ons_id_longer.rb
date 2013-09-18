class OnsIdLonger < ActiveRecord::Migration
  def self.up
    change_column :blacklisted_postcodes, :ons_id, :string, :limit => 20
    change_column :constituencies, :ons_id, :string, :limit => 20
    change_column :manual_postcodes, :ons_id, :string, :limit => 20
    change_column :postcodes, :ons_id, :string, :limit => 20
  end

  def self.down
    change_column :blacklisted_postcodes, :ons_id, :string, :limit => 3
    change_column :constituencies, :ons_id, :string, :limit => 3
    change_column :manual_postcodes, :ons_id, :string, :limit => 3
    change_column :postcodes, :ons_id, :string, :limit => 3
  end
end
