class DropUpmystreetcodes < ActiveRecord::Migration
  def self.up
    drop_table :up_my_street_codes
  end

  def self.down
    create_table :up_my_street_codes do |t|
      t.integer :code
      t.string :constituency
    end
  end
end
