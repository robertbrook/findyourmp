class AddRecipientEmailToMessages < ActiveRecord::Migration

  def self.up
    add_column :messages, :recipient_email, :string
  end

  def self.down
    remove_column :messages, :recipient_email
  end
end
