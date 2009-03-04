class CreateConstituencyLists < ActiveRecord::Migration
  def self.up
    create_table :constituency_lists do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :constituency_lists
  end
end
