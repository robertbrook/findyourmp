class MessageMailer < ActionMailer::Base

  def sent(message, sent_at = Time.now)
    subject    message.subject
    recipients "#{message.recipient} <#{message.test_recipient_email}>"
    from       message.test_from
    sent_on    sent_at

    body       :message => message
  end

  def confirm(message, sent_at = Time.now)
    subject    "Confirmation of your message to #{message.recipient}"
    recipients "#{message.sender} <#{message.test_sender_email}>"
    from       message.test_from
    sent_on    sent_at

    body       :message => message
  end

end
