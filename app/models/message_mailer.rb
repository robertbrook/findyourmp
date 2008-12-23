class MessageMailer < ActionMailer::Base

  class << self
    def parse_email text
      email = TMail::Address.parse(text)
      domain = email.domain
      if domain
        if domain.downcase[/\.([a-z]+)/] && ($1.size >= 2)
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
    subject    message.subject
    recipients "#{message.recipient} <#{message.test_recipient_email}>"
    from       message.test_from
    sent_on    sent_at

    body       :message => message
  end

  def confirm(message, sent_at = Time.now)
    subject    "Confirmation of your message to #{message.recipient}"
    recipients "#{message.sender} <#{message.sender_email}>"
    from       message.test_from
    sent_on    sent_at

    body       :message => message
  end

end
