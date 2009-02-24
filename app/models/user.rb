class User < ActiveRecord::Base

  acts_as_authentic # :crypto_provider => Authlogic::CryptoProviders::BCrypt

  def deliver_password_reset_instructions!
    reset_perishable_token!
    PasswordResetNotifier.deliver_password_reset_instructions(self)
  end
end
