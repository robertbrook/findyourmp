class CreatePostcodes < ActiveRecord::Migration
  def self.up
    create_table :postcodes do |t|
      t.string :code, :limit => 7
      t.integer :constituency_id
    end

    add_index :postcodes, :constituency_id
  end

  def self.down
    drop_table :postcodes
  end
end
