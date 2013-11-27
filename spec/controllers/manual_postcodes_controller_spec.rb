require './spec/spec_helper'

describe ManualPostcodesController do
  before do
    current_user = mock_model User
    current_user.stub!(:admin?).and_return(true)
    controller.stub!(:current_user).and_return(current_user)
  end
  
  describe "when finding route for action" do
    it 'should display index' do
      params_from(:get, "/admin/manual_postcodes").should == {:controller => "manual_postcodes", :action => "index"}
    end
  end
  
  describe "when displaying the index page" do
    it 'should assign an array of blacklisted postcodes to the view' do
      ManualPostcode.stub!(:all).and_return ["postcode1", "postcode2"]
      get :index
      
      assigns[:manual_list].should == ["postcode1", "postcode2"]
    end
  end
  
  describe "when removing a manual postcode" do
    before do
      @code = 'NS21AB'
      @manual_postcode = mock('ManualPostcode', :code => @code, :ons_id => 1, :constituency_id => 1, :name => 'Test')
    end
    
    def do_get code
      get :remove, :code => code
    end
    
    it "should invoke remove and redirect to the index page given a valid code" do
      ManualPostcode.should_receive(:find_by_code).and_return @manual_postcode
      @manual_postcode.should_receive(:remove).and_return true
      
      do_get @code
      
      response.should redirect_to('/admin/manual_postcodes')
    end
  end
  
  describe "when adding a new postcode to the manual list" do
    before do
      @code = 'NS21AB'
      @blacklisted_postcode = mock('ManualPostcode', :code => @code, :ons_id => 1, :constituency_id => 1, :name => 'Test')
    end
    
    describe "when given a valid postcode" do      
      it "should assign the code to flash memory" do
        Postcode.should_receive(:find_by_code).and_return true
        
        post :new, :manual_postcodes => { :code => @code }
        flash[:code].should == @code
      end
      
      it "should assign a list of constituencies to the view if the postcode does not already exist" do
        Postcode.should_receive(:find_by_code).and_return nil
        Constituency.should_receive(:all_constituencies).and_return ['constituency1', 'constituency2']
        
        post :new, :manual_postcodes => { :code => @code }
        assigns[:constituencies].should == ['constituency1', 'constituency2']
      end
    end
    
    describe "when a constituency is chosen" do
      it 'should retrieve the code from flash memory and redirect after performing an update' do
        flash[:code] = @code
        constituency_id = 1
        ons_id = 2
        @constituency = mock('Constituency', :constituency_id => constituency_id, :ons_id => ons_id)
        Constituency.should_receive(:find_by_id).with(constituency_id).and_return @constituency
        ManualPostcode.should_receive(:add_manual_postcode).with(@code, constituency_id, ons_id).and_return @postcode
      
        post :new, :manual_postcodes => { :constituency => constituency_id }, :commit => 'Create manual postcode'
        flash[:code].should == nil
        response.should redirect_to('/admin/manual_postcodes')
      end
    end
  end
end