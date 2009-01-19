class Message < ActiveRecord::Base

  belongs_to :constituency

  before_validation_on_create :populate_defaulted_fields
  before_validation :populate_postcode_and_sender_is_constituent

  validates_presence_of :sender, :message => 'Please enter your full name'
  validates_presence_of :sender_email, :message => 'Please enter your email address'
  validates_presence_of :postcode, :message => 'Please enter your postcode'
  validates_presence_of :subject, :message => 'Please enter your subject'
  validates_presence_of :message, :message => 'Please enter your message'
  validates_presence_of :authenticity_token
  validates_presence_of :recipient_email
  validates_presence_of :recipient
  validates_inclusion_of :sent, :in => [true, false]

  validate :email_valid
  validate :postcode_valid
  validate :message_not_default

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

    def populate_defaulted_fields
      self.recipient = constituency.member_name
      self.recipient_email = constituency.member_email
      self.sent = 0
    end

    def populate_postcode_and_sender_is_constituent
      self.sender_is_constituent = 0

      if @post_code = Postcode.find_postcode_by_code(postcode)
        self.postcode = @post_code.code_with_space

        if @post_code.in_constituency? constituency
          self.sender_is_constituent = 1
        end
      end
    end

    def postcode_valid
      errors.add('postcode', 'Please enter a valid postcode') unless @post_code
    end

    def message_not_default
      if message
        msg = String.new message
        default_message.split.each{|word| msg.sub!(word,'')}
        if msg.gsub(/\n|\r| |,/,'').blank?
          errors.add('message', "Please enter your message")
        end
      end
    end

    def email_valid
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
end
