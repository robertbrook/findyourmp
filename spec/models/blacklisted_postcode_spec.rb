require File.dirname(__FILE__) + '/../spec_helper'

describe BlacklistedPostcode do
  before do
    @blacklisted_postcode = BlacklistedPostcode.new
  end
  
  describe 'when asked to find blacklisted postcode by code' do
    it 'should return a match' do
      code = 'N12SD'
      BlacklistedPostcode.should_receive(:find_by_code).with(code).and_return @blacklisted_postcode
      BlacklistedPostcode.find_by_code(code).should == @blacklisted_postcode
    end
    
    it 'should return nil if given nil code' do
      BlacklistedPostcode.find_by_code(nil).should be_nil
    end
  end
  
  describe 'when asked to restore a blacklisted postcode' do
    before do
      @postcode = mock_model(Postcode)
      @ons_id = 444
      @constituency_id = 5
      @code = 'N215SD'
      @blacklisted_postcode.stub!(:ons_id).and_return @ons_id
      @blacklisted_postcode.stub!(:constituency_id).and_return @constituency_id
      @blacklisted_postcoed.stub!(:code).and_return @code
    end
    
    it 'should insert a new Postcode entry if none already exists' do
      Postcode.should_receive(:find_by_code).and_return nil
      Postcode.should_receive(:create).and_return @postcode
      @blacklisted_postcode.should_receive(:delete)
      
      @blacklisted_postcode.restore
    end
    
    it 'should not attempt to create a new Postcode entry if one already exists' do
      Postcode.should_receive(:find_by_code).and_return @postcode
      Postcode.should_not_receive(:create)
      @blacklisted_postcode.should_receive(:delete)
      
      @blacklisted_postcode.restore
    end
    
    it 'should not delete the BlacklistedPostcode if the creation of a new Postcode fails' do
      Postcode.should_receive(:find_by_code).and_return nil
      Postcode.should_receive(:create).and_return nil
      @blacklisted_postcode.should_not_receive(:delete)
      
      @blacklisted_postcode.restore
    end
  end
end