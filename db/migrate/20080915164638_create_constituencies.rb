class CreateConstituencies < ActiveRecord::Migration
  def self.up
    create_table :constituencies do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :constituencies
  end
end
