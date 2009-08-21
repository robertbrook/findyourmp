class CreateManualPostcodes < ActiveRecord::Migration
  def self.up
    create_table :manual_postcodes do |t|
      t.string :code,  :limit => 7
      t.integer :constituency_id
      t.integer :ons_id

      t.timestamps
    end
    
    add_index :manual_postcodes, :code
  end

  def self.down
    drop_table :manual_postcodes
  end
end
