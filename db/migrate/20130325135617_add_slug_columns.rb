class AddSlugColumns < ActiveRecord::Migration
  def self.up
    add_column :constituencies, :slug, :string, :limit => 128
    add_index :constituencies, :slug, unique: true
  end
  
  def self.down
    remove_column :constituencies, :slug
  end
end
