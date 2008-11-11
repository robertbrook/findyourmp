class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :constituency_id
      t.string :sender_email
      t.string :sender
      t.string :recipient
      t.string :address
      t.string :postcode
      t.string :subject
      t.text :message
      t.boolean :sent
      t.time :sent_on

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
