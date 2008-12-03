class Message < ActiveRecord::Base

  belongs_to :constituency

  validates_presence_of :recipient
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

  private
    def populate_defaulted_fields
      self.recipient = constituency.member_name
      self.sent = 0
    end
end
