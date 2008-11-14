require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  before(:each) do
    @constituency_id = "value for constituency_id"
    @valid_attributes = {
      :constituency_id => @constituency_id,
      :sender_email => "value for sender_email",
      :sender => "value for sender",
      :address => "value for address",
      :postcode => "value for postcode",
      :subject => "value for subject",
      :message => "value for message",
      :sent => false,
      :sent_on => Time.now
    }
  end

  assert_model_belongs_to :constituency

  def self.assert_checks_presence attribute
    eval %Q|it 'should be invalid when #{attribute} is missing' do
      @valid_attributes.delete(attribute)
      message = Message.new(@valid_attributes)
      message.valid?.should be_false
    end|
  end

  # assert_checks_presence :sender_email
  # assert_checks_presence :sender
  # assert_checks_presence :recipient
  # assert_checks_presence :address
  # assert_checks_presence :postcode
  # assert_checks_presence :subject
  # assert_checks_presence :message
  # assert_checks_presence :sent

  it "should create a new instance given valid attributes" do
    nil_conditions = {:readonly=>nil, :select=>nil, :include=>nil, :conditions=>nil}
    @member_name = 'member_name'
    constituency = mock_model(Constituency, :member_name=>@member_name, :id => @constituency_id)
    Constituency.should_receive(:find).with(@constituency_id, nil_conditions).and_return constituency
    message = Message.create!(@valid_attributes)
    message.recipient.should == @member_name
  end
end
