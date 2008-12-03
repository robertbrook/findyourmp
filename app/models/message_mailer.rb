class MessageMailer < ActionMailer::Base

  def sent(message, sent_at = Time.now)
    subject    message.subject
    recipients message.recipient
    from       "no_reply@findyourmp.parliament.uk"
    sent_on    sent_at

    body       :message => message
  end

  def confirm(message, sent_at = Time.now)
    subject    "Confirmation of your message to #{message.recipient}"
    recipients "#{message.sender} <#{message.sender_email}>"
    from       "no_reply@findyourmp.parliament.uk"
    sent_on    sent_at

    body       :message => message
  end

end
