class RemoveSentOnFromMessagesAndAddSentAt < ActiveRecord::Migration
  def self.up
    remove_column :messages, :sent_on
    add_column :messages, :sent_at, :datetime
    add_index :messages, :sent_at

    Message.all.each {|m| m.sent_at = m.created_at; m.save}
  end

  def self.down
    remove_column :messages, :sent_at
    add_column :messages, :sent_on, :time
  end
end
