class AdminController < ApplicationController

  before_filter :require_user

  def index
    @sent_message_count = Message.sent.count
    @attempted_send_message_count = Message.attempted_send.count
    @messages = [] # Message.all
  end

  def sent_by_month
    @month = Date.parse(params[:yyyy_mm].sub('_','-') + '-01')
    @sent_by_constituency = Message.sent_by_constituency(@month)
  end

  def sent
    @sent_by_month_count = Message.sent_by_month
  end

  def attempted_send
    @attempted_send_by_month_count = Message.attempted_send_by_month
  end
end
