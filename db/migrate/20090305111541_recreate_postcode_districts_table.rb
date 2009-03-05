class RecreatePostcodeDistrictsTable < ActiveRecord::Migration
  def self.up
    drop_table :postcode_districts

    create_table :postcode_districts do |t|
      t.string :district, :limit => 4
      t.integer :constituency_id
    end

    add_index :postcode_districts, :district
  end

  def self.down
    drop_table :postcode_districts

    create_table :postcode_districts, :id => false, :primary_key => 'district' do |t|
      t.string :district, :limit => 4
      t.integer :constituency_id
    end

    add_index :postcode_districts, [:district], :name => "index_postcode_districts_on_district", :unique => false
  end
end
