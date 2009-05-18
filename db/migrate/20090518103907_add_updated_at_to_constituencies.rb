class AddUpdatedAtToConstituencies < ActiveRecord::Migration
  def self.up
    add_column :constituencies, :updated_at, :datetime

    Constituency.find_each do |c|
      c.updated_at = Time.now
      c.save!
    end
  end

  def self.down
    remove_column :constituencies, :updated_at
  end
end
