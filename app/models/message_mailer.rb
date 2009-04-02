class MessageMailer < ActionMailer::Base

  self.delivery_method = :activerecord

  class << self

    def noreply_email
      ActionMailer::Base.smtp_settings[:user_name]
    end

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
    recipients "#{message.recipient} <#{message.recipient_email}>"
    from       MessageMailer.noreply_email
    reply_to   message.sender_email
    sent_on    sent_at

    body       :message => message
  end

  def confirm(message, sent_at = Time.now)
    subject    "Confirmation of your message to #{message.recipient}"
    recipients "#{message.sender} <#{message.sender_email}>"
    from       MessageMailer.noreply_email
    sent_on    sent_at

    body       :message => message
  end

end
