class RemoveAttemptedSendFromMessages < ActiveRecord::Migration
  def self.up
    remove_index :messages, :attempted_send
    remove_column :messages, :attempted_send
  end

  def self.down
    add_column :messages, :attempted_send, :boolean
    add_index :messages, :attempted_send
  end
end
