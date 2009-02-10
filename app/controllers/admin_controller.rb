class AdminController < ApplicationController

  before_filter :require_user

  def index
    @sent_message_count = Message.sent.count
    @attempted_send_message_count = Message.attempted_send.count
    @draft_message_count = Message.draft.count
    @messages = [] # Message.all
  end

  def sent
    @sent_by_month_count = Message.sent_by_month
  end

  def draft
    @draft_by_month_count = Message.draft_by_month
  end

  def attempted_send
    @attempted_send_by_month_count = Message.attempted_send_by_month
  end
end
