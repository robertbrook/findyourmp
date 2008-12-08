#
# For Rails 2.x:
#   A copy of this file should be placed in RAILS_ROOT/initializers/
#   A file named mailer.yml should be placed in RAILS_ROOT/config/
#     See mailer.yml.sample
#

mailer_conf = "#{RAILS_ROOT}/config/mailer.yml"

if File.exists?(mailer_conf)
  require "smtp_tls"

  mailer_config = File.open(mailer_conf)
  mailer_options = YAML.load(mailer_config)
  ActionMailer::Base.smtp_settings = mailer_options
elsif ActionMailer::Base.delivery_method == :smtp
  raise "config/mailer.yml not found, failed to setup smtp_tls plugin"
end
