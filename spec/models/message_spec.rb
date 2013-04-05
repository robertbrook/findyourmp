require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do

  def self.assert_checks_presence attribute
    eval %Q|it 'should be invalid when #{attribute} is missing' do
      Postcode.stub!(:find_postcode_by_code).and_return mock('postcode', :code_with_space => 'N1 2SD', :in_constituency? => true) unless "#{attribute}" == 'postcode'
      @valid_attributes.delete(attribute)
      message = Message.new(@valid_attributes)
      message.stub!(:constituency).and_return mock('constituency', :member_name=>nil, :member_email => nil, :name => nil)
      message.valid?.should be_false
      message.errors[:#{attribute}].should_not be_nil
    end|
  end

  before(:each) do
    @constituency_id = "value for constituency_id"
    @postcode = "N1 2SD"
    @valid_attributes = {
      :constituency_id => @constituency_id,
      :sender => "Joe Smith",
      :sender_email => "value.for@sender.email",
      :address => "100 Path
      Islington
      London",
      :postcode => @postcode,
      :subject => "value for subject",
      :message => "value for message"
    }
    Message.delete_all
  end

  assert_checks_presence :sender
  assert_checks_presence :sender_email
  assert_checks_presence :constituency_name
  assert_checks_presence :recipient
  assert_checks_presence :recipient_email
  assert_checks_presence :postcode
  assert_checks_presence :subject
  assert_checks_presence :message

  def mock_message_setup
    nil_conditions = {:readonly=>nil, :select=>nil, :include=>nil, :conditions=>nil}
    @constituency_name = 'Islington South'
    @member_name = 'member_name'
    @member_email = 'member_name@parl.uk'
    constituency = mock_model(Constituency, :member_email => @member_email, :member_name=>@member_name, :id => @constituency_id, :name => @constituency_name)
    Constituency.should_receive(:find).with(@constituency_id, nil_conditions).any_number_of_times.and_return constituency
    @post_code = mock('postcode', :code_with_space => @postcode, :in_constituency? => true)
    Postcode.should_receive(:find_postcode_by_code).with(@postcode).any_number_of_times.and_return @post_code
  end

  describe "when asked to delete stored messages" do
    it 'should delete message contents and subject when older than given number of weeks' do
      message = mock(Message)
      weeks = 4
      delete_past_date = (Date.today - 4.weeks).to_s(:yyyy_mm_dd)
      conditions = "sent = true AND created_at < '#{delete_past_date}'"

      message = mock(Message)
      message.should_receive(:message=).with('DELETED')
      message.should_receive(:subject=).with('DELETED')
      message.should_receive(:save!)

      Message.should_receive(:find_each).with(:conditions => conditions).and_yield message
      Message.delete_stored_message_contents weeks
    end
    it 'should delete messages older than given number of months' do
      message = mock(Message)
      months = 4
      delete_past_date = (Date.today - 4.months).to_s(:yyyy_mm_dd)
      conditions = "sent = true AND created_at < '#{delete_past_date}'"

      Message.should_receive(:delete_all).with(conditions)
      Message.delete_stored_messages months
    end
  end

  describe 'creating' do
    before do
      mock_message_setup
    end

    it "should create a new instance given valid attributes" do
      message = Message.new()
      @valid_attributes.each do |var_name, value|
        eval("message.#{var_name.to_s} = value")
      end
      message.valid?.should be_true
      message.recipient.should == @member_name
      message.address.should == "100 Path
Islington
London"
    end

    describe "when asked for sender_via_fymp_email" do
      it 'should return sender name in quotes, with noreply email address' do
        message = Message.new(@valid_attributes)
        message.sender_via_fymp_email.should == %Q|"Joe Smith via FindYourMP" <noreply@parliament.uk>|
      end
    end
    describe "sender's postcode is in constituency" do
      it 'should return true for sender_in_constituency' do
        message = Message.new(@valid_attributes)
        message.valid?.should be_true
        message.sender_is_constituent.should be_true
      end
    end

    describe "sender's postcode is not in constituency" do
      before do
        @post_code.stub!(:in_constituency?).and_return false
        @message = Message.new(@valid_attributes)
      end
      it 'should return false for sender_in_constituency' do
        @message.valid?.should be_true
        @message.sender_is_constituent.should be_false
      end

      it 'should show sender_details correctly' do
        @message.valid?.should be_true
        @message.sender_details.should == "Name: Joe Smith
Email: value.for@sender.email
Address:
100 Path
Islington
London
Postcode: N1 2SD
This postcode is not in Islington South."
      end
    end

    describe 'sender email is invalid' do
      it 'should not be valid without top level domain' do
        attributes = @valid_attributes.merge(:sender_email=>'inv@lid')
        message = Message.new(attributes)
        message.valid?.should be_false
      end

      it 'should not be valid with single letter top level domain' do
        attributes = @valid_attributes.merge(:sender_email=>'inv@lid.x')
        message = Message.new(attributes)
        message.valid?.should be_false
      end
    end

    describe 'sender email has parliament.uk domain' do
      it 'should not be valid without' do
        attributes = @valid_attributes.merge(:sender_email=>'me@parliament.uk')
        message = Message.new(attributes)
        message.valid?.should be_false
      end
    end

    describe 'sender email is valid' do
      it 'should be valid' do
        attributes = @valid_attributes.merge(:sender_email=>'v@lid.com')
        message = Message.new(attributes)
        message.valid?.should be_true
      end
    end
  end

  describe 'when asked to deliver message' do
    before do
      mock_message_setup
      @message = Message.new(@valid_attributes)
      @message.valid?.should be_true
      @message.stub!(:save!)

      @summary = MessageSummary.new
      MessageSummary.stub!(:find_from_message).and_return @summary
      @summary.stub!(:save!)

      MessageMailer.stub!(:deliver_sent)
      MessageMailer.stub!(:deliver_confirm)
      @now = Time.now.utc
      Time.stub!(:now).and_return mock('time', :utc=>@now)
    end
    describe 'and sending is successful' do
      it 'should deliver sent message' do
        MessageMailer.should_receive(:deliver_sent).with(@message)
        @message.deliver
      end
      it 'should deliver confirm message' do
        MessageMailer.should_receive(:deliver_confirm).with(@message)
        @message.deliver
      end
      it 'should set sent to true' do
        @message.sent.should be_false
        @message.deliver.should be_true
        @message.sent.should be_true
      end
      it 'should set sent_at to current time' do
        @message.sent_at.should be_nil
        @message.deliver
        @message.sent_at.year.should == @now.year
        @message.sent_at.month.should == @now.month
        @message.sent_at.day.should == @now.day
      end
      it 'should save message summary after sending' do
        @message.should_receive(:save!)
        @summary.should_receive(:increment_count)
        @summary.should_receive(:save!)
        @message.deliver
      end
    end
    describe 'and exception occurs when sending' do
      before do
        MessageMailer.should_receive(:deliver_sent).with(@message).and_raise mock(Exception)
      end
      it 'should leave sent as false' do
        @message.sent.should be_false
        @message.deliver.should be_false
        @message.sent.should be_false
      end
      it 'should leave sent_at as nil' do
        @message.sent_at.should be_nil
        @message.deliver
        @message.sent_at.should be_nil
      end
      it 'should save message state after sending' do
        @message.should_receive(:save!)
        @message.deliver
      end
    end
  end

  describe 'after successfully delivering message' do
    before do
      mock_message_setup
      @message = Message.create(@valid_attributes)
      MessageMailer.stub!(:deliver_sent)
      MessageMailer.stub!(:deliver_confirm)
    end
    after do
      Message.delete_all
    end
    it 'should count sent correctly' do
      @message.deliver
      MessageSummary.count.should == 1
    end
    it 'should count sent by month correctly' do
      @message.deliver
      MessageSummary.sent_by_month.should == [[Date.today.at_beginning_of_month, 1]]
    end
  end

  describe 'after attempted send of message' do
    before do
      mock_message_setup
      @message = Message.create(@valid_attributes)
      MessageMailer.should_receive(:deliver_sent).with(@message).and_raise mock(Exception)
    end
    after do
      Message.delete_all
    end
    it 'should count sent correctly' do
      @message.deliver
      Message.count.should == 1
    end
  end

  describe 'when asked for count of sent messages' do
    before do
      mock_message_setup
      @month = Date.new(2009,1,1).to_time
      @month1 = Date.new(2009,2,1).to_time
      @month2 = Date.new(2009,3,1).to_time
      @message =Message.new(@valid_attributes.merge(:sent_at=>@month))
      @message.created_at = @month
      @message.save
      @message2 =Message.new(@valid_attributes.merge(:sent_at=>@month2))
      @message2.created_at = @month2
      @message2.save
      mock_message_setup
      @message.sent = true; @message.save
      @message2.sent = true; @message2.save
    end
    it 'should count sent messages and return result' do
      Message.sent.count.should == 2
    end
    describe 'by month' do
      it 'should count sents by month' do
        Message.sent_by_month.to_a.should == [[@month,1],[@month1,0],[@month2,1]]
      end
    end
  end

end
