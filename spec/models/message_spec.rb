require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do

  def self.assert_checks_presence attribute
    eval %Q|it 'should be invalid when #{attribute} is missing' do
      @valid_attributes.delete(attribute)
      message = Message.new(@valid_attributes)
      message.stub!(:constituency).and_return mock('constituency', :member_name=>nil, :member_email => nil)
      message.valid?.should be_false
    end|
  end

  before(:each) do
    @constituency_id = "value for constituency_id"
    @authenticity_token = "054e4e1d3d5bd8e9e446490734ce6d1bbc65cfea"
    @valid_attributes = {
      :constituency_id => @constituency_id,
      :sender => "value for sender",
      :sender_email => "value for sender_email",
      :authenticity_token => @authenticity_token,
      :address => "value for address",
      :postcode => "value for postcode",
      :subject => "value for subject",
      :message => "value for message",
      :sent => false,
      :sent_on => Time.now
    }
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
  assert_checks_presence :sent

  it "should create a new instance given valid attributes" do
    nil_conditions = {:readonly=>nil, :select=>nil, :include=>nil, :conditions=>nil}
    @member_name = 'member_name'
    @member_email = 'member_name@parl.uk'
    constituency = mock_model(Constituency, :member_email => @member_email, :member_name=>@member_name, :id => @constituency_id)
    Constituency.should_receive(:find).with(@constituency_id, nil_conditions).and_return constituency
    message = Message.new(@valid_attributes)
    message.valid?.should be_true
    message.recipient.should == @member_name
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
      @message = Message.new(@valid_attributes)
      MessageMailer.stub!(:deliver_sent)
      MessageMailer.stub!(:deliver_confirm)
      @message.stub!(:save!)
    end
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
      @message.should_receive(:save!)
      @message.deliver
      @message.sent.should be_true
    end
  end
end
