require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do

  def self.assert_checks_presence attribute
    eval %Q|it 'should be invalid when #{attribute} is missing' do
      Postcode.stub!(:find_postcode_by_code).and_return mock('postcode', :code_with_space => 'N1 2SD', :in_constituency? => true) unless "#{attribute}" == 'postcode'
      @valid_attributes.delete(attribute)
      message = Message.new(@valid_attributes)
      message.stub!(:constituency).and_return mock('constituency', :member_name=>nil, :member_email => nil)
      message.valid?.should be_false
      message.errors[:#{attribute}].should_not be_nil
    end|
  end

  before(:each) do
    @constituency_id = "value for constituency_id"
    @authenticity_token = "054e4e1d3d5bd8e9e446490734ce6d1bbc65cfea"
    @postcode = "N1 2SD"
    @valid_attributes = {
      :constituency_id => @constituency_id,
      :sender => "value for sender",
      :sender_email => "value.for@sender.email",
      :authenticity_token => @authenticity_token,
      :address => "value for address",
      :postcode => @postcode,
      :subject => "value for subject",
      :message => "value for message"
    }
    Message.delete_all
  end

  assert_model_belongs_to :constituency

  assert_checks_presence :sender
  assert_checks_presence :sender_email
  assert_checks_presence :authenticity_token
  assert_checks_presence :recipient
  assert_checks_presence :recipient_email
  assert_checks_presence :postcode
  assert_checks_presence :subject
  assert_checks_presence :message

  def mock_message_setup
    nil_conditions = {:readonly=>nil, :select=>nil, :include=>nil, :conditions=>nil}
    @member_name = 'member_name'
    @member_email = 'member_name@parl.uk'
    constituency = mock_model(Constituency, :member_email => @member_email, :member_name=>@member_name, :id => @constituency_id)
    Constituency.should_receive(:find).with(@constituency_id, nil_conditions).and_return constituency
    @post_code = mock('postcode', :code_with_space => @postcode, :in_constituency? => true)
    Postcode.should_receive(:find_postcode_by_code).with(@postcode).and_return @post_code
  end

  describe 'creating' do
    before do
      mock_message_setup
    end

    it "should create a new instance given valid attributes" do
      message = Message.new(@valid_attributes)
      message.valid?.should be_true
      message.recipient.should == @member_name
    end

    describe "sender's postcode is in constituency" do
      it 'should return true for sender_in_constituency' do
        message = Message.new(@valid_attributes)
        message.valid?.should be_true
        message.sender_is_constituent.should be_true
      end
    end

    describe "sender's postcode is not in constituency" do
      it 'should return false for sender_in_constituency' do
        @post_code.stub!(:in_constituency?).and_return false
        message = Message.new(@valid_attributes)
        message.valid?.should be_true
        message.sender_is_constituent.should be_false
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

  describe 'when asked to authenticate authenticity_token' do
    before do
      @message = Message.new(@valid_attributes)
    end
    it 'should return false if given token is nil' do
      @message.authenticate(nil).should be_false
    end
    it 'should return false if given token does not match own authenticity_token' do
      @message.authenticate('bad_token').should be_false
    end
    it 'should return false if given token matches own authenticity_token' do
      @message.authenticate(@authenticity_token).should be_true
    end
  end

  describe 'when asked to deliver message' do
    before do
      mock_message_setup
      @message = Message.new(@valid_attributes)
      @message.valid?.should be_true
      MessageMailer.stub!(:deliver_sent)
      MessageMailer.stub!(:deliver_confirm)
      @now = Time.now.utc
      Time.stub!(:now).and_return mock('time', :utc=>@now)
      @message.stub!(:save!)
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
        @message.deliver
        @message.sent.should be_true
      end
      it 'should set sent_at to current time' do
        @message.sent_at.should be_nil
        @message.deliver
        @message.sent_at.year.should == @now.year
        @message.sent_at.month.should == @now.month
        @message.sent_at.day.should == @now.day
      end
      it 'should leave attempted_send as false' do
        @message.attempted_send.should be_false
        @message.deliver
        @message.attempted_send.should be_false
      end
      it 'should save message state after sending' do
        @message.should_receive(:save!)
        @message.deliver
      end
    end
    describe 'and exception occurs when sending' do
      before do
        MessageMailer.should_receive(:deliver_sent).with(@message).and_raise mock(Exception)
      end
      it 'should leave sent as false' do
        @message.sent.should be_false
        @message.deliver
        @message.sent.should be_false
      end
      it 'should leave sent_at as nil' do
        @message.sent_at.should be_nil
        @message.deliver
        @message.sent_at.should be_nil
      end
      it 'should set attempted_send to true' do
        @message.attempted_send.should be_false
        @message.deliver
        @message.attempted_send.should be_true
      end
      it 'should save message state after sending' do
        @message.should_receive(:save!)
        @message.deliver
      end
    end
  end

  describe 'when asked for count of attempted send messages' do
    it 'should count attempted send messages and return result' do
      Message.attempted_send.count.should == 0
    end
    describe 'by month' do
      it 'should count attempted_sends by month' do
        results = mock('hash')
        Message.should_receive(:count_by_month).with(:attempted_send).and_return results
        Message.attempted_send_by_month.should == results
      end
    end
  end

  describe 'when asked for count of sent messages' do
    it 'should count sent messages and return result' do
      Message.sent.count.should == 0
    end
    describe 'by month' do
      it 'should count sents by month' do
        results = mock('hash')
        Message.should_receive(:count_by_month).with(:sent).and_return results
        Message.sent_by_month.should == results
      end
    end
  end

  describe 'when asked for count of draft messages' do
    it 'should count draft messages and return result' do
      Message.draft.count.should == 0
    end

    describe 'by month' do
      it 'should count drafts by month' do
        results = mock('hash')
        Message.should_receive(:count_by_month).with(:draft).and_return results
        Message.draft_by_month.should == results
      end
    end
  end

end
