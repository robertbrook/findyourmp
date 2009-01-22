class AddAttemptedSendAndMailerErrorToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :attempted_send, :boolean
    add_column :messages, :mailer_error, :string

    add_index :messages, :sent
    add_index :messages, :attempted_send
  end

  def self.down
    remove_column :messages, :attempted_send
    remove_column :messages, :mailer_error

    remove_index :messages, :sent
  end
end
