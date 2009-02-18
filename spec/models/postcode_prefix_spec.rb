require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodePrefix do

  assert_model_belongs_to :constituency
  
  before do
     @postcode = PostcodePrefix.new
     @constituency_name = 'Islington South'
     @member_name = 'Edmund Husserl'
     @constituency = mock_model(Constituency, :id => 123, :ons_id =>801, :friendly_id => 'islington-south', :name => @constituency_name, :member_name => @member_name)
     @other_constituency = mock_model(Constituency, :id => 124)
     @postcode.stub!(:constituency).and_return @constituency
     @matches = [ @postcode ]
   end
  
  describe 'when asked to find postcode by prefix' do
    it 'should return match including its constituency' do
      prefix = 'N1'
      PostcodePrefix.should_receive(:find).and_return @matches
      PostcodePrefix.find_all_by_prefix(prefix).should == @matches
      
      @matches.first.id.should == @constituency.friendly_id
      @matches.first.constituency_name.should == @constituency.name
    end
    it 'should return nil if given non-matching code' do
      prefix = 'invalid'
      PostcodePrefix.should_receive(:find).and_return []
      PostcodePrefix.find_all_by_prefix(prefix).should be_nil
    end
  end
  
end