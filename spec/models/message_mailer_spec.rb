require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessageMailer do

  before(:each) do
    @constituency_id = "value for constituency_id"
    @authenticity_token = "054e4e1d3d5bd8e9e446490734ce6d1bbc65cfea"

    @recipient_name = "MP name"
    @recipient_email = "mp@parl.uk"
    @sender_name = "Sender name"
    @no_reply_email = "noreply@parliament.uk"
    @sender_via_fymp = %Q|"Sender name via FindYourMP" <noreply@parliament.uk>|
    @sender_email = "sender@public.uk"
    @subject = "Subject"
    @contents = "My message"
    @sender_details = "details"


    Message.stub!(:noreply_email).and_return @no_reply_email

    @message = mock(Message, :constituency_id => @constituency_id,
      :sender => @sender_name,
      :sender_email => @sender_email,
      :sender_details => @sender_details,
      :sender_via_fymp_email => @sender_via_fymp,
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
      @email.subject.should == "[FindYourMP] #{@subject}"
    end
    it 'should set from correctly' do
      @email.from.should == [@no_reply_email]
    end
    it 'should set recipients correctly' do
      # @email.to.should == "#{@recipient_name} <#{@recipient_email}>"
      @email.to.should == [@recipient_email]
    end

    describe 'and sender is not a constituent' do
      it 'should set body correctly' do
        @message.stub!(:sender_is_constituent).and_return false
        @email = MessageMailer.create_sent(@message)
        expected = [""]
        expected << "You are receiving this message from the Find Your MP service at http://findyourmp.parliament.uk. To comment on this service or amend your details, contact the Information Office: #{ Message.feedback_email }."
        expected << "\n\n"
        expected << "Replies to this email will be sent to the sender's address and not to the Find Your MP service."
        expected << "\n\n"
        expected << "================================================================="
        expected << "\n\n"
        expected << "The message was sent with the following sender details:\n\n#{@sender_details}\n\n"
        expected << "================================================================="
        expected << "\n\n"
        expected << "The message was sent with the following text:\n\n#{@contents}\n\n"
        expected << "================================================================="
        @email.body.strip.should == expected.join('')
      end
    end
  end

  describe 'when asked to create confirm email' do
    before do
      @email = MessageMailer.create_confirm(@message)
    end
    it 'should set subject correctly' do
      @email.subject.should == "[FindYourMP] Confirmation of your message: #{@subject}"
    end
    it 'should set from correctly' do
      @email.from.should == [@no_reply_email]
    end
    it 'should set recipients correctly' do
      # @email.to.should == "#{@sender_name} <#{@sender_email}>"
      @email.to.should == [@sender_email]
    end
    it 'should set body correctly' do
      expected = ["You are receiving this message from the Find Your MP service at http://findyourmp.parliament.uk.\n\n"]
      expected << "=================================================================\n\n"
      expected << "Your message was sent with the following sender details submitted:\n\n#{@sender_details}\n\n"
      expected << "=================================================================\n\n"
      expected << "Your message was sent with the following text:\n\n#{@contents}\n\n"
      expected << "=================================================================\n\n"
      expected << "If you wish to comment on this service, please mail the Information Office at #{Message.feedback_email}"
      @email.body.strip.should == expected.join('')
    end
  end
end
