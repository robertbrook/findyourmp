class DropConstituenciesListTable < ActiveRecord::Migration
  def self.up
    drop_table :constituency_lists
  end

  def self.down
    create_table :constituency_lists do |t|
      t.timestamps
    end
  end
end
