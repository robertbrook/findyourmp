class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :name
      t.integer :constituency_id
    end

    add_index :members, :constituency_id
  end

  def self.down
    drop_table :members
  end
end
