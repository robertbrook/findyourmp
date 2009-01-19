class AddSenderIsConstituentToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_is_constituent, :boolean
    add_column :messages, :constituency_name, :string
  end

  def self.down
    remove_column :messages, :sender_is_constituent
    remove_column :messages, :constituency_name
  end
end
