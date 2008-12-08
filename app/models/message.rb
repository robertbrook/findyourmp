class Message < ActiveRecord::Base

  belongs_to :constituency

  validates_presence_of :recipient
  validates_presence_of :recipient_email
  validates_presence_of :sender
  validates_presence_of :sender_email
  validates_presence_of :authenticity_token
  validates_presence_of :postcode
  validates_presence_of :subject
  validates_presence_of :message
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

  def test_from
    "no_reply@findyourmp.parl.uk"
  end

  def test_recipient_email
    RAILS_ENV == 'development' ? test_email : recipient_email
  end

  def test_sender_email
    RAILS_ENV == 'development' ? test_email : sender_email
  end

  private

    def test_email
      ActionMailer::Base.smtp_settings[:user_name]
    end

    def populate_defaulted_fields
      self.recipient = constituency.member_name
      self.recipient_email = constituency.member_email
      self.sent = 0
    end
end
