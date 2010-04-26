class OnsIdToString < ActiveRecord::Migration
  def self.up
    change_column :blacklisted_postcodes, :ons_id, :string, :limit => 3
    change_column :constituencies, :ons_id, :string, :limit => 3
    change_column :manual_postcodes, :ons_id, :string, :limit => 3
    change_column :postcodes, :ons_id, :string, :limit => 3
  end

  def self.down
    change_column :blacklisted_postcodes, :ons_id, :integer
    change_column :constituencies, :ons_id, :integer
    change_column :manual_postcodes, :ons_id, :integer
    change_column :postcodes, :ons_id, :string
  end
end
