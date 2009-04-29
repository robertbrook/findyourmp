class CreateUpMyStreetCodes < ActiveRecord::Migration
  def self.up
    create_table :up_my_street_codes do |t|
      t.integer :code
      t.string :constituency
    end

    add_index :up_my_street_codes, :code
  end

  def self.down
    drop_table :up_my_street_codes
  end
end
