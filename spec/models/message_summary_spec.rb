require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessageSummary do

  describe 'creating from message' do
    before do
      @constituency_id = "value for constituency_id"
      @postcode = "N1 2SD"
      @time = Time.now
      @recipient_email = "value.for@recipient.email"
      @recipient = "recipient"
      @valid_attributes = {
        :constituency_id => @constituency_id,
        :sender => "value for sender",
        :sender_email => "value.for@sender.email",
        :recipient_email => @recipient_email,
        :recipient => @recipient,
        :address => "value for address",
        :postcode => @postcode,
        :subject => "value for subject",
        :message => "value for message",
        :sent_at => @time
      }
      @message = Message.new(@valid_attributes)
    end

    it 'should set recipient_email, recipient, constituency_name and sent_at' do
      summary = MessageSummary.new
      summary.message = @message
      summary.recipient_email.should == @recipient_email
      summary.recipient.should == @recipient
      summary.sent_at.should == @time
    end
  end

end
