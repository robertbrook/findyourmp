class AddAuthenticationTokenToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :authenticity_token, :string
  end

  def self.down
    remove_column :messages, :authenticity_token
  end
end
