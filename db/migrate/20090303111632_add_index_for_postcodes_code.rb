class AddIndexForPostcodesCode < ActiveRecord::Migration
  def self.up
    add_index :postcodes, :code
  end

  def self.down
    remove_index :postcodes, :code
  end
end
