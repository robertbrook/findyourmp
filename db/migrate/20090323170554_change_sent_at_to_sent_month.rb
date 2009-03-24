class ChangeSentAtToSentMonth < ActiveRecord::Migration
  def self.up
    remove_column :message_summaries, :sent_at
    add_column :message_summaries, :sent_month, :date
    add_column :message_summaries, :count, :integer

    add_index :message_summaries, :sent_month
    add_index :message_summaries, :constituency_name
    add_index :message_summaries, :recipient
    add_index :message_summaries, :recipient_email
  end

  def self.down
    remove_index :message_summaries, :sent_month
    remove_index :message_summaries, :constituency_name
    remove_index :message_summaries, :recipient
    remove_index :message_summaries, :recipient_email

    remove_column :message_summaries, :sent_month
    remove_column :message_summaries, :count
    add_column :message_summaries, :sent_at, :datetime
  end
end
