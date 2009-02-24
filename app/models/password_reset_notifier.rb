class PasswordResetNotifier < ActionMailer::Base

  # default_url_options[:host] = "findyourmp.parliament.uk"
  default_url_options[:host] = 'localhost'
  default_url_options[:port] = 3000
  default_url_options[:protocol] = 'http'

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          MessageMailer.noreply_email
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
