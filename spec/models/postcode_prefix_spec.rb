require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodePrefix do

  assert_model_belongs_to :constituency
  
  before do
     @postcode = Postcode.new
     @constituency_name = 'Islington South'
     @member_name = 'Edmund Husserl'
     @constituency = mock_model(Constituency, :id => 123, :ons_id =>801, :name => @constituency_name, :member_name => @member_name)
     @other_constituency = mock_model(Constituency, :id => 124)
     @postcode.stub!(:constituency).and_return @constituency
     @postcode.stub!(:constituency_id).and_return @constituency.id
     @postcode.stub!(:ons_id).and_return @constituency.ons_id
   end
  
  describe 'when asked to find postcode by prefix' do
    it 'should return match including its constituency and member' do
      prefix = 'N1'
      PostcodePrefix.should_receive(:find_all_by_prefix).with(prefix).and_return @postcode
      PostcodePrefix.find_all_by_prefix(prefix).should == @postcode
    end
    it 'should return nil if given nil code' do
      PostcodePrefix.find_all_by_prefix(nil).should be_nil
    end
  end
  
end