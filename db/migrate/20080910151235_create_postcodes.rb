class CreatePostcodes < ActiveRecord::Migration
  def self.up
    create_table :postcodes do |t|
      t.string :code
      t.integer :constituency_id
    end
  end

  def self.down
    drop_table :postcodes
  end
end
