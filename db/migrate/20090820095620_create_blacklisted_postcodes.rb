class CreateBlacklistedPostcodes < ActiveRecord::Migration
  def self.up
    create_table :blacklisted_postcodes do |t|
      t.string :code,  :limit => 7
      t.integer :constituency_id
      t.integer :ons_id

      t.timestamps
    end
    
    add_index :blacklisted_postcodes, :code
  end

  def self.down
    drop_table :blacklisted_postcodes
  end
end
