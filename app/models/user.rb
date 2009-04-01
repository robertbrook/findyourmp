class User < ActiveRecord::Base

  acts_as_authentic # :crypto_provider => Authlogic::CryptoProviders::BCrypt

  class << self
    # to create initial admin user
    def create_admin_user(password, email)
      if count > 0
        raise 'admin user already exists'
      elsif password.blank?
        raise 'password cannot be blank'
      elsif email.blank?
        raise 'email cannot be blank'
      else
        User.create!(:login=>'admin',:email=>email,:admin=>true,:password=>password,:password_confirmation=>password)
      end
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    PasswordResetNotifier.deliver_password_reset_instructions(self)
  end
end
