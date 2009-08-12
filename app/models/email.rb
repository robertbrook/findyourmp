class Email < ActiveRecord::Base

  named_scope :waiting
  
  before_create :check_header

  class << self
    def waiting_to_be_sent_count
      count
    end

    def waiting_to_be_sent_by_month_count
      count_by_month(:waiting, true, :created_on)
    end
  end

  private
  
    def check_header     
      to_line = ""
      new_to_line = ""
      from_line = ""
      new_from_line = ""
       
      unless mail.nil?
        mail.each do |line|
          if line[0..5] == 'From: '
            unless line.include?('@')
              from_line = line
              new_from_line = line.gsub("\r\n", " <#{from}>\r\n")
            end
          end
          if line[0..3] == 'To: '
            unless line.include?('@')
              to_line = line
              new_to_line = line.gsub("\r\n", " <#{to}>\r\n")
            end
          end
          if line[0..1] == "\r\n"
            break
          end
        end
        unless new_to_line.empty?
          mail.gsub!(to_line, new_to_line)
        end
        unless new_from_line.empty?
          mail.gsub!(from_line, new_from_line)
        end
      end
    end
end
