class Message < ActiveRecord::Base

  belongs_to :constituency

  validates_presence_of :recipient
  validates_presence_of :recipient_email
  validates_presence_of :sender
  validates_presence_of :sender_email
  validate :valid_email?
  validates_presence_of :authenticity_token
  validates_presence_of :postcode
  validates_presence_of :subject
  validates_presence_of :message
  validate :message_not_default
  validates_inclusion_of :sent, :in => [true, false]

  before_validation_on_create :populate_defaulted_fields

  def authenticate authenticity_token
    authenticity_token && (authenticity_token == self.authenticity_token) ? true : false
  end

  def deliver
    MessageMailer.deliver_sent(self)
    MessageMailer.deliver_confirm(self)
    self.sent = 1
    save!
  end

  def default_message
    "Dear #{constituency.member_name},\n\n\n\nYours sincerely,\n\n"
  end

  def test_from
    test_email
  end

  def test_recipient_email
    RAILS_ENV == 'development' ? test_email : recipient_email
  end

  def test_sender_email
    RAILS_ENV == 'development' ? test_email : sender_email
  end

  private

    def message_not_default
      if message
        msg = String.new message
        default_message.split.each{|w| msg.sub!(w,'')}
        if msg.gsub(/\n|\r| |,/,'').blank?
          errors.add('message', "Please enter your message")
        end
      end
    end

    def valid_email?
      unless sender_email.blank?
        begin
          email = MessageMailer.parse_email(sender_email)
          if email.domain == 'parliament.uk'
            errors.add('sender_email', 'Please enter a non parliament.uk email address')
          else
            self.sender_email = email.address
          end
        rescue
          errors.add('sender_email', "Please enter a valid email address")
        end
      end
    end

    def test_email
      ActionMailer::Base.smtp_settings[:user_name]
    end

    def populate_defaulted_fields
      self.recipient = constituency.member_name
      self.recipient_email = constituency.member_email
      self.sent = 0
    end
end
