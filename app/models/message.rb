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
  validates_inclusion_of :attempted_send, :in => [true, false]

  validate :email_valid
  validate :postcode_valid
  validate :message_not_default

  named_scope :sent, :conditions => {:sent => true}
  named_scope :draft, :conditions => {:sent => false, :attempted_send => false}
  named_scope :attempted_send, :conditions => {:attempted_send => true}

  class << self
    def sent_by_month
      count_by_month(:sent)
    end
    def draft_by_month
      count_by_month(:draft)
    end
    def attempted_send_by_month
      count_by_month(:attempted_send)
    end
    protected
      def count_by_month type
        first_month = send(type).minimum(:sent_at).at_beginning_of_month
        last_month = send(type).maximum(:sent_at).at_beginning_of_month
        months = [first_month]
        next_month = first_month.next_month
        while (next_month <= last_month)
          months << next_month
          next_month = next_month.next_month
        end
        count_by_month = ActiveSupport::OrderedHash.new
        months.each do |month|
          conditions = "MONTH(sent_at) = #{month.month} AND YEAR(sent_at) = #{month.year}"
          count_by_month[month] = send(type).count(:conditions => conditions)
        end
        count_by_month
      end
  end

  def authenticate authenticity_token
    authenticity_token && (authenticity_token == self.authenticity_token) ? true : false
  end

  def deliver
    begin
      MessageMailer.deliver_sent(self)
      MessageMailer.deliver_confirm(self)
      self.attempted_send = 0
      self.sent = 1
      self.sent_at = Time.now.utc
    rescue Exception => e
      self.attempted_send = 1
      self.mailer_error = e.message + "\n" + e.backtrace.join("\n")
      logger.error e
    end
    save!
    return self.sent
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
      self.attempted_send = 0
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
