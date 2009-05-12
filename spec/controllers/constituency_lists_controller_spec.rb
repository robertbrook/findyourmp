require File.dirname(__FILE__) + '/../spec_helper'

describe ConstituencyListsController do

  describe 'when not logged in as admin' do
    it 'should redirect to login page' do
      get :edit
      response.should redirect_to(new_user_session_url)
      
      get :update
      response.should redirect_to(new_user_session_url)
    end
  end
  
  describe 'when logged in as admin' do
    before do
      current_user = mock_model User
      current_user.stub!(:has_role?).with('admin').and_return(true)
      controller.stub!(:current_user).and_return(current_user)
    end
    
    describe 'when asked to edit' do
      before do
        get :edit
      end
      
      it 'should not redirect' do
        response.should_not redirect_to(new_user_session_url)
      end
      
      it 'should assign ConstituencyList to the view' do
        assigns[:constituency_list].class.should == ConstituencyList
      end
    end
    
    describe 'when asked to update' do
      before do
        @header = "Constituency	Member	Party"
        @line_1 = %Q|"Islington West"\t"Duncan McCloud"\t"(SDP)"\t"http://biographies.parliament.uk/parliament/default.asp?id=1"\t"dm@parliament.uk"	"http://www.dm.co.uk/"|
        @items = "#{@header}
  #{@line_1}"
        @constituency_1 = mock(Constituency, 
          :name =>'Islington West', 
          :member_name => 'Duncan McCloud', 
          :member_party => 'SDP', 
          :member_email => 'dm@parliament.uk', 
          :member_biography_url => 'http://biographies.parliament.uk/parliament/default.asp?id=1',
          :member_website => 'http://www.dm.co.uk/',
          :valid? => true)
        @constituency_2 = mock(Constituency, :name =>'Aberdeen North', :member_name => 'Mr Frank Doran', :valid? => true)
        @constituency_3 = mock(Constituency, :name =>'Aberdeen Centre', :member_name => 'Mr Frank Doran', :valid? => true)

        Constituency.stub!(:all).and_return [@constituency_1, @constituency_2, @constituency_3]
        
        Constituency.should_receive(:load_tsv_line).with(@line_1).any_number_of_times.and_return [@constituency_1, @constituency_1]
      end
      
      it 'should not redirect' do
        response.should_not redirect_to(new_user_session_url)
      end
      
      it 'should assign the correct values to the view' do
        post :update, :constituency_list => {:items => @line_1}
        
        assigns[:unchanged_constituencies].should be_empty
        assigns[:ommitted_constituencies].size.should == 2
        assigns[:unrecognized_constituencies].should be_empty
        assigns[:invalid_constituencies].should be_empty
        assigns[:changed_constituencies].size.should == 1
      end
      
    end
  end

end
