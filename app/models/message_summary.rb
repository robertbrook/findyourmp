class MessageSummary < ActiveRecord::Base

  validates_presence_of :recipient_email
  validates_presence_of :recipient
  validates_presence_of :constituency_name
  validates_presence_of :sent_month

  scope :sent
  scope :sent_in_month, lambda { |date| {:conditions => ["MONTH(sent_month) = ? AND YEAR(sent_month) = ?" , date.month, date.year]} }

  class << self

    def find_from_message message
      summary = find_by_constituency_name_and_recipient_and_recipient_email_and_sent_month(
        message.constituency_name, message.recipient, message.recipient_email, message.sent_at.beginning_of_month)
      unless summary
        summary = MessageSummary.new
        summary.populate_from(message)
      end
      summary
    end

    def sent_by_constituency date
      messages = sent_in_month(date)
      sent = ActiveSupport::OrderedHash.new
      groups = messages.group_by(&:constituency_name)
      groups.keys.compact.sort.each do |constituency|
        sent[constituency] = groups[constituency]
      end
      sent
    end

    def sent_by_month
      count_by_month = []
      first_month = send(:sent).minimum(:sent_month)

      if first_month
        first_month = first_month
        last_month = send(:sent).maximum(:sent_month)
        months = [first_month]
        next_month = first_month.next_month
        while (next_month <= last_month)
          months << next_month
          next_month = next_month.next_month
        end
        months.each do |month|
          conditions = ["sent_month = ?", month]
          count_by_month << [month, sent_in_month(month).collect(&:count).sum]
        end
      end
      count_by_month
    end
  end

  def increment_count
    self.count = self.count.next
  end

  def populate_from message
    self.recipient_email = message.recipient_email
    self.recipient = message.recipient
    self.constituency_name = message.constituency_name
    self.sent_month = message.sent_at.beginning_of_month
    self.count = 0
  end
end
