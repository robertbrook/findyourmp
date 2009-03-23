class CreateMessageSummaries < ActiveRecord::Migration
  def self.up
    create_table :message_summaries do |t|
      t.string :recipient
      t.datetime :sent_at
      t.string :constituency_name
      t.string :recipient_email

      t.timestamps
    end
  end

  def self.down
    drop_table :message_summaries
  end
end
