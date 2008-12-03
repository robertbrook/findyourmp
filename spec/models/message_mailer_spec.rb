require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessageMailer do

  before(:each) do
    @constituency_id = "value for constituency_id"
    @authenticity_token = "054e4e1d3d5bd8e9e446490734ce6d1bbc65cfea"

    @recipient = "value for recipient"
    @sender_name = "value for sender"
    @sender_email = "value for sender_email"
    @subject = "value for subject"
    @contents = "value for message"

    @no_reply_email = "no_reply@findyourmp.parliament.uk"

    @message = mock(Message, :constituency_id => @constituency_id,
      :sender => @sender_name,
      :sender_email => @sender_email,
      :recipient => @recipient,
      :authenticity_token => @authenticity_token,
      :address => "value for address",
      :postcode => "value for postcode",
      :subject => @subject,
      :message => @contents,
      :sent => false )
  end

  describe 'when asked to create sent email' do
    before do
      @email = MessageMailer.create_sent(@message)
    end
    it 'should set subject correctly' do
      @email.subject.should == @subject
    end
    it 'should set from correctly' do
      @email.from.should == [@no_reply_email]
    end
    it 'should set recipients correctly' do
      # @email.to.should == "#{@recipient}"
    end
    it 'should set body correctly' do
      @email.body.strip.should == @contents
    end
  end

  describe 'when asked to create confirm email' do
    before do
      @email = MessageMailer.create_confirm(@message)
    end
    it 'should set subject correctly' do
      @email.subject.should == "Confirmation of your message to #{@recipient}"
    end
    it 'should set from correctly' do
      @email.from.should == [@no_reply_email]
    end
    it 'should set recipients correctly' do
      # @email.to.should == "#{@sender_name} <#{@sender_email}>"
    end
    it 'should set body correctly' do
      @email.body.strip.should == "Confirmation that your message to #{@recipient} has been sent."
    end
  end
end
