class User < ActiveRecord::Base

  acts_as_authentic # :crypto_provider => Authlogic::CryptoProviders::BCrypt

end
