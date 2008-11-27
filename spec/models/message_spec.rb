require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do

  def self.assert_checks_presence attribute
    eval %Q|it 'should be invalid when #{attribute} is missing' do
      @valid_attributes.delete(attribute)
      message = Message.new(@valid_attributes)
      message.stub!(:constituency).and_return mock('constituency', :member_name=>nil)
      message.valid?.should be_false
    end|
  end

  before(:each) do
    @constituency_id = "value for constituency_id"
    @valid_attributes = {
      :constituency_id => @constituency_id,
      :sender => "value for sender",
      :sender_email => "value for sender_email",
      :authenticity_token => "054e4e1d3d5bd8e9e446490734ce6d1bbc65cfea",
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
  assert_checks_presence :postcode
  assert_checks_presence :subject
  assert_checks_presence :message
  assert_checks_presence :sent

  it "should create a new instance given valid attributes" do
    nil_conditions = {:readonly=>nil, :select=>nil, :include=>nil, :conditions=>nil}
    @member_name = 'member_name'
    constituency = mock_model(Constituency, :member_name=>@member_name, :id => @constituency_id)
    Constituency.should_receive(:find).with(@constituency_id, nil_conditions).and_return constituency
    message = Message.create!(@valid_attributes)
    message.recipient.should == @member_name
  end
end
