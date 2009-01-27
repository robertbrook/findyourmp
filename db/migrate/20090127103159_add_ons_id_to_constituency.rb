class AddOnsIdToConstituency < ActiveRecord::Migration
  def self.up
    add_column :constituencies, :ons_id, :integer
    add_index :constituencies, :ons_id
  end

  def self.down
    remove_column :constituencies, :ons_id
  end
end
