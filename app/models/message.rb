class Message < ActiveRecord::Base

  belongs_to :constituency

  before_validation_on_create :populate_defaulted_fields
  before_validation :populate_postcode_and_sender_is_constituent
  before_validation :clean_address_whitespace
  before_validation :clean_message_whitespace

  validates_presence_of :sender, :message => 'Please enter your full name'
  validates_presence_of :sender_email, :message => 'Please enter your email address'
  validates_presence_of :postcode, :message => 'Please enter your postcode'
  validates_presence_of :subject, :message => 'Please enter your subject'
  validates_presence_of :message, :message => 'Please enter your message'
  validates_presence_of :recipient_email
  validates_presence_of :recipient
  validates_presence_of :constituency_name
  validates_inclusion_of :sent, :in => [true, false]

  validate :email_valid
  validate :postcode_valid
  validate :message_not_default

  named_scope :sent, :conditions => {:sent => true}
  named_scope :sent_in_month, lambda { |date| {:conditions => ["sent = 1 AND MONTH(created_at) = ? AND YEAR(created_at) = ?" , date.month, date.year]} }

  class << self

    def delete_stored_message_contents no_of_weeks
      delete_past_date = (Date.today - no_of_weeks.weeks).to_s(:yyyy_mm_dd)
      conditions = "sent = true AND created_at < '#{delete_past_date}'"

      find_each(:conditions => conditions) do |message|
        message.subject = 'DELETED'
        message.message = 'DELETED'
        message.save!
      end
    end

    def delete_stored_messages no_of_months
      delete_past_date = (Date.today - no_of_months.months).to_s(:yyyy_mm_dd)
      conditions = "sent = true AND created_at < '#{delete_past_date}'"
      delete_all(conditions)
    end

    def noreply_email
      "noreply@parliament.uk"
    end

    def feedback_email
      "hcinfo@parliament.uk"
    end

    def sent_by_month_count
      waiting = waiting_to_be_sent_by_month_count
      MessageSummary.sent_by_month.collect do |month, count|
        waiting_count = waiting.assoc(month) ? waiting.assoc(month)[1] : 0
        [month, count - waiting_count ]
      end
    end

    def sent_by_constituency(month)
      MessageSummary.sent_by_constituency(month)
    end

    def waiting_to_be_sent_by_month_count
      Email.waiting_to_be_sent_by_month_count.collect do |month, emails|
        [month, emails.size / 2]
      end
    end

    def sent_message_count
      MessageSummary.all.collect(&:count).sum - waiting_to_be_sent_count
    end

    def waiting_to_be_sent_count
      Email.waiting_to_be_sent_count / 2
    end

    def sent_by_month
      count_by_month(:sent, false).to_a.sort{|a,b| a[0]<=>b[0]}
    end
  end

  def deliver
    begin
      MessageMailer.deliver_sent(self)
      MessageMailer.deliver_confirm(self)
      self.sent = true
      self.sent_at = Time.now.utc
      save!

      summary = MessageSummary.find_from_message(self)
      summary.increment_count
      summary.save!
    rescue Exception => e
      self.mailer_error = e.message + "\n" + e.backtrace.join("\n")
      logger.error e
      save!
    end
    return self.sent
  end

  def sender_via_fymp_email
    %Q|"#{sender} via FindYourMP" <#{Message.noreply_email}>|
  end

  def default_message
    constituency ? "Dear #{constituency.member_name},\n\n\n\nYours sincerely,\n\n" : ''
  end

  def clean_message_whitespace
    if self.message
      text = []
      self.message.each_line { |line| text << line.strip }
      self.message = text.join("\n")
    end
  end

  def clean_address_whitespace
    if self.address
      text = []
      self.address.each_line { |line| text << line.strip }
      self.address = text.join("\n")
    end
  end

  def address_or_not_given
    if address.blank?
      'not given'
    else
      lines = []
      address.each_line {|line| lines << line.strip}
      lines.join("\n")
    end
  end

  def in_constituency_message
    if sender_is_constituent
      "This postcode is in #{constituency_name}."
    else
      "This postcode is not in #{constituency_name}."
    end
  end

  def sender_details
    details = []
    details << "Name: #{sender}"
    details << "Email: #{sender_email}"
    details << "Address:\n#{address_or_not_given}"
    details << "Postcode: #{postcode}"
    details << in_constituency_message
    details.join("\n")
  end

  private

    def populate_defaulted_fields
      self.recipient = constituency.member_name
      self.recipient_email = constituency.member_email
      self.constituency_name = constituency.name
      self.sent = 0
    end

    def populate_postcode_and_sender_is_constituent
      self.sender_is_constituent = 0

      if @post_code = Postcode.find_postcode_by_code(postcode)
        self.postcode = @post_code.code_with_space

        if constituency && @post_code.in_constituency?(constituency)
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
end
