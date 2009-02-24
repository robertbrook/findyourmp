require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessageMailer do

  before(:each) do
    @constituency_id = "value for constituency_id"
    @authenticity_token = "054e4e1d3d5bd8e9e446490734ce6d1bbc65cfea"

    @recipient_name = "MP name"
    @recipient_email = "mp@parl.uk"
    @sender_name = "Sender name"
    @sender_email = "sender@public.uk"
    @subject = "Subject"
    @contents = "My message"

    @no_reply_email = "no_reply@findyourmp.parliament.uk"

    MessageMailer.stub!(:noreply_email).and_return @no_reply_email
    
    @message = mock(Message, :constituency_id => @constituency_id,
      :sender => @sender_name,
      :sender_email => @sender_email,
      :test_sender_email => @sender_email,
      :recipient => @recipient_name,
      :recipient_email => @recipient_email,
      :test_recipient_email => @recipient_email,
      :test_from => @no_reply_email,
      :authenticity_token => @authenticity_token,
      :address => "value for address",
      :postcode => "value for postcode",
      :sender_is_constituent => true,
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
      # @email.to.should == "#{@recipient_name} <#{@recipient_email}>"
      @email.to.should == [@recipient_email]
    end
    it 'should set body correctly' do
      @email.body.strip.should == "Message from constituent:\n\n\n#{@contents}"
    end

    describe 'and sender is not a constituent' do
      it 'should set body correctly' do
        @message.stub!(:sender_is_constituent).and_return false
        @email = MessageMailer.create_sent(@message)
        @email.body.strip.should == "Message from non-constituent:\n\n\n#{@contents}"
      end
    end
  end

  describe 'when asked to create confirm email' do
    before do
      @email = MessageMailer.create_confirm(@message)
    end
    it 'should set subject correctly' do
      @email.subject.should == "Confirmation of your message to #{@recipient_name}"
    end
    it 'should set from correctly' do
      @email.from.should == [@no_reply_email]
    end
    it 'should set recipients correctly' do
      # @email.to.should == "#{@sender_name} <#{@sender_email}>"
      @email.to.should == [@sender_email]
    end
    it 'should set body correctly' do
      @email.body.strip.should == "Confirmation that your message to #{@recipient_name} has been sent with the following text:\n\n#{@contents}"
    end
  end
end
