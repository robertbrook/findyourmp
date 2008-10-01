class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :name
      t.integer :constituency_id
    end
  end

  def self.down
    drop_table :members
  end
end
