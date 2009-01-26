class AdminController < ApplicationController

  before_filter :respond_unauthorized_if_not_admin

  def index
    @sent_message_count = Message.sent.count
    @attempted_send_message_count = Message.attempted_send.count
    @draft_message_count = Message.draft.count
    @messages = [] # Message.all
  end

end
