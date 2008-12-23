class AddMemberRequestedContactUrlToConstituencies < ActiveRecord::Migration
  def self.up
    add_column :constituencies, :member_requested_contact_url, :string
  end

  def self.down
    remove_column :constituencies, :member_requested_contact_url
  end
end
