require File.dirname(__FILE__) + '/../spec_helper'

describe BlacklistedPostcode do
  
  describe 'when asked to find blacklisted postcode by code' do
    before do
      @postcode = BlacklistedPostcode.new
    end
    
    it 'should return a match' do
      code = 'N12SD'
      BlacklistedPostcode.should_receive(:find_by_code).with(code).and_return @postcode
      
      BlacklistedPostcode.find_by_code(code).should == @postcode
    end
    
    it 'should return nil if given nil code' do
      BlacklistedPostcode.find_by_code(nil).should be_nil
    end
  end
  
end