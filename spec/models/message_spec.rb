require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  before(:each) do
    @valid_attributes = {
      :constituency_id => "value for constituency_id",
      :sender_email => "value for sender_email",
      :sender => "value for sender",
      :recipient => "value for recipient",
      :address => "value for address",
      :postcode => "value for postcode",
      :subject => "value for subject",
      :message => "value for message",
      :sent => false,
      :sent_on => Time.now
    }
  end

  assert_model_belongs_to :constituency

  it "should create a new instance given valid attributes" do
    Message.create!(@valid_attributes)
  end
end
