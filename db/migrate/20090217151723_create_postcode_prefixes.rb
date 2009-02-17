class CreatePostcodePrefixes < ActiveRecord::Migration
  def self.up
    create_table :postcode_prefixes, :id => false, :primary_key => 'prefix' do |t|
      t.string :prefix, :limit => 4
      t.integer :constituency_id
    end
    
    add_index :postcode_prefixes, :prefix
  end

  def self.down
    drop_table :postcode_prefixes
  end
end