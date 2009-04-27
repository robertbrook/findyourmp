class AddSenderIpToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_ip_address, :string
  end

  def self.down
    remove_column :messages, :sender_ip_address
  end
end
