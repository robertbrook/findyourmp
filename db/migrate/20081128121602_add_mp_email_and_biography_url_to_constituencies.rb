class AddMpEmailAndBiographyUrlToConstituencies < ActiveRecord::Migration
  def self.up
    add_column :constituencies, :member_party, :string
    add_column :constituencies, :member_email, :string
    add_column :constituencies, :member_biography_url, :string
    add_column :constituencies, :member_visible, :boolean
  end

  def self.down
    remove_column :constituencies, :member_party
    remove_column :constituencies, :member_email
    remove_column :constituencies, :member_biography_url
    remove_column :constituencies, :member_visible
  end
end
