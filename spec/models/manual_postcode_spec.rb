require './spec/spec_helper'

describe ManualPostcode do
  before do
    @code = 'BA140AB'
    @constituency_id = 506
    @ons_id = 111
    
    @postcode = mock_model(Postcode, :code => @code, :constituency_id => @constituency_id, :ons_id => @ons_id)
  end  
  
  describe 'when asked to add a manual postcode' do
    before do
      @manual_postcode = mock_model(ManualPostcode, :code => @code, :constituency_id => @constituency_id, :ons_id => @ons_id)
    end
    
    it 'should create new Postcode and ManualPostcode records if neither pre-exist' do
      Postcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:create).and_return @manual_postcode
      Postcode.should_receive(:create).and_return @postcode
      
      ManualPostcode.add_manual_postcode(@code, @constituency_id, @ons_id).should == true
    end
    
    it 'should just create a new postcode if the ManualPostcode record already exists' do
      Postcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:find_by_code).once.and_return @manual_postcode
      Postcode.should_receive(:create).and_return @postcode
      ManualPostcode.should_not_receive(:create)
      
      ManualPostcode.add_manual_postcode(@code, @constituency_id, @ons_id).should == true
    end
    
    it 'should not perform any updates if the Postcode already exists' do
      Postcode.should_receive(:find_by_code).once.and_return @postcode
      ManualPostcode.should_not_receive(:create)
      Postcode.should_not_receive(:create)
      
      ManualPostcode.add_manual_postcode(@code, @constituency_id, @ons_id).should == true
    end
    
    it 'should not update Postcode if a ManualPostcode insert fails' do
      Postcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:create).with(:code => @code, :constituency_id => @constituency_id, :ons_id => nil)
      Postcode.should_not_receive(:create)
      
      ManualPostcode.add_manual_postcode(@code, @constituency_id, nil).should == false
    end
    
    it 'should remove the new ManualPostcode if inserting new Postcode fails' do
      Postcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:find_by_code).once.and_return nil
      ManualPostcode.should_receive(:create).and_return @manual_postcode
      Postcode.should_receive(:create).and_return nil
      @manual_postcode.should_receive(:delete)
      
      ManualPostcode.add_manual_postcode(@code, @constituency_id, @ons_id).should == false
    end
  end
  
  describe 'when asked to remove a manual postcode' do
    before do
      @manual_postcode = ManualPostcode.new
    end
            
    it 'should delete the Postcode entry if it exists' do
      Postcode.should_receive(:find_by_code).and_return @postcode
      @postcode.should_receive(:delete)
      @manual_postcode.should_receive(:delete)
       
      @manual_postcode.remove
    end
     
    it 'should still delete the Manual Postcode entry if there is no matching Postcode' do
      Postcode.should_receive(:find_by_code).and_return nil
      @postcode.should_not_receive(:delete)
      @manual_postcode.should_receive(:delete)
       
      @manual_postcode.remove
    end
  end
end