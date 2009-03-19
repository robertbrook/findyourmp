class Email < ActiveRecord::Base

  named_scope :waiting

  class << self
    def waiting_to_be_sent_count
      count
    end

    def waiting_to_be_sent_by_month_count
      count_by_month(:waiting, true, :created_on)
    end
  end

end
