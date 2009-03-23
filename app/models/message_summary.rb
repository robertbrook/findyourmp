class MessageSummary < ActiveRecord::Base

  validates_presence_of :recipient_email
  validates_presence_of :recipient
  validates_presence_of :constituency_name
  validates_presence_of :sent_at

  named_scope :sent
  named_scope :sent_in_month, lambda { |date| {:conditions => ["MONTH(sent_at) = ? AND YEAR(sent_at) = ?" , date.month, date.year]} }

  class << self

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
      count_by_month(:sent, false, :sent_at).to_a.sort{|a,b| a[0]<=>b[0]}
    end
  end

  def message= message
    self.recipient_email = message.recipient_email
    self.recipient = message.recipient
    self.constituency_name = message.constituency_name
    self.sent_at = message.sent_at
  end

end
