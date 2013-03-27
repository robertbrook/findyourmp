require './spec/spec_helper'

describe BlacklistedPostcodesController do
  before do
    current_user = mock_model User
    current_user.stub!(:admin?).and_return(true)
    controller.stub!(:current_user).and_return(current_user)
  end
  
  describe "when finding route for action" do
     it 'should display index' do
       {:get => "/admin/blacklist" }.should route_to(:controller => "blacklisted_postcodes", :action => "index")
     end
   end
   
  describe "when displaying the index page" do
    it 'should assign an array of blacklisted postcodes to the view' do
      BlacklistedPostcode.stub!(:all).and_return ["postcode1", "postcode2"]
      get :index
      
      assigns[:blacklist].should == ["postcode1", "postcode2"]
    end
  end
  
  describe "when restoring a blacklisted postcode" do
    before do
      @code = 'NS21AB'
      @blacklisted_postcode = mock('BlacklistedPostcode', :code => @code, :ons_id => 1, :constituency_id => 1, :name => 'Test')
    end
    
    def do_get code
      get :restore, :code => code
    end
    
    it "should invoke restore and redirect to the index page given a valid code" do
      BlacklistedPostcode.should_receive(:find_by_code).and_return @blacklisted_postcode
      @blacklisted_postcode.should_receive(:restore).and_return true
      
      do_get @code
      
      response.should redirect_to('/admin/blacklist')
    end
    
    it "should redirect to the index page without invoking restore given an invalid code" do
      BlacklistedPostcode.should_receive(:find_by_code).and_return nil
      @blacklisted_postcode.should_not_receive(:restore)
      
      do_get 'invalid'
      
      response.should redirect_to('/admin/blacklist')
    end
  end
  
  describe "when adding a new postcode to the blacklist" do
    before do
      @code = 'NS21AB'
      @blacklisted_postcode = mock('BlacklistedPostcode', :code => @code, :ons_id => 1, :constituency_id => 1, :name => 'Test')
    end
    
    describe "when searching for a postcode" do
      it "should assign the code to flash memory" do
        Postcode.should_receive(:find_by_code)
        
        post :new, :blacklist => { :code => @code }
        flash[:code].should == @code
      end
    end
    
    describe "when an update is confirmed" do      
      it 'should retrieve the code from flash memory and redirect after performing an update' do
        @postcode = mock('Postcode')
        flash[:code] = @code
        @controller.stub!(:flash).and_return(flash)
        Postcode.should_receive(:find_by_code).with(@code).and_return @postcode
        @postcode.should_receive(:blacklist)
        
        post :new, :commit => 'Confirm'
        flash[:code].should == nil
        response.should redirect_to('/admin/blacklist')
      end
    end
  end
end