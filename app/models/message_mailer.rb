require 'mail'

class MessageMailer < ActionMailer::Base

  self.delivery_method = :activerecord

  class << self
    def parse_email text
      email = Mail::Address.new(text)
      domain = email.domain
      if domain
        if domain.downcase[/\.([a-z]+)$/] && ($1.size >= 2)
          return email
        else
          raise Exception('email must have top level domain')
        end
      else
        raise Exception('email must have @domain')
      end
    end
  end

  def sent(message, sent_at = Time.now)
    subject    "[FindYourMP] #{message.subject}"
    recipients %Q|"#{message.recipient}" <#{message.recipient_email}>|
    from       message.sender_via_fymp_email
    reply_to   message.sender_email
    sent_on    sent_at

    body       :message => message
  end

  def confirm(message, sent_at = Time.now)
    subject    "[FindYourMP] Confirmation of your message: #{message.subject}"
    recipients %Q|"#{message.sender}" <#{message.sender_email}>|
    from       Message.noreply_email
    sent_on    sent_at

    body       :message => message
  end

end
