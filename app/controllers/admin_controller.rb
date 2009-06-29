require 'rss'

class AdminController < ApplicationController

  before_filter :require_user
  before_filter :require_admin_user, :only => [:shutdown, :mailserver_status]

  def index
    @sent_message_count = Message.sent_message_count
    @waiting_to_be_sent_count = Message.waiting_to_be_sent_count
  end

  def sent_by_month
    @month = Date.parse(params[:yyyy_mm].sub('_','-') + '-01')
    @sent_by_constituency = Message.sent_by_constituency(@month)
  end

  def sent
    @sent_by_month_count = Message.sent_by_month_count
  end

  def waiting_to_be_sent
    @waiting_to_be_sent_by_month_count = Message.waiting_to_be_sent_by_month_count
  end
  
  def stats
    @memory_stats = Message.memory_stats
  end
  
  def mailserver_status
    IO.popen("ping -c 4 mail.messagingengine.com") do |stream|
      @ping_test = stream.readlines
    end
    
    begin
      output=""
      feed = RSS::Parser.parse(open('http://status.fastmail.fm/feed/').read, false)
      i = 0
      feed.channel.items.each do |item|
        output += "<p>#{item.pubDate}<br /> <a href=\"#{item.link}\">#{item.title}</a></p>" if i < 4
        i+=1
      end
      @feed = output
    rescue
      @feed = "Error trying to open http://status.fastmail.fm/feed/"
    end
  end
  
  def shutdown
    if request.post?
      if params[:commit] == 'Shutdown site'
        `rake apache:shutdown`
      end
    end
  end
end
