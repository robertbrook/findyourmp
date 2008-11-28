class AddMemberWebsiteToConstituencies < ActiveRecord::Migration
  def self.up
    add_column :constituencies, :member_website, :string
  end

  def self.down
    remove_column :constituencies, :member_website
  end
end
