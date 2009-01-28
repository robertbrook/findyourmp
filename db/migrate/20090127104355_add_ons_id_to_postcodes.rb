class AddOnsIdToPostcodes < ActiveRecord::Migration
  def self.up
    add_column :postcodes, :ons_id, :integer
    add_index :postcodes, :ons_id
  end

  def self.down
    remove_column :postcodes, :ons_id
  end
end
