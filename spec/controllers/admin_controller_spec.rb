require File.dirname(__FILE__) + '/../spec_helper'

describe AdminController do

  describe "when finding route for action" do
    it 'should display index' do
      params_from(:get, "/admin").should == {:controller => "admin", :action => "index"}
    end
  end

  describe 'when not logged in as admin' do
    it 'should redirect to login page' do
      get :index
      response.should redirect_to(new_user_session_url)
    end
  end

  describe 'when logged in as admin' do
    before do
      current_user = mock_model User
      current_user.stub!(:has_role?).with('admin').and_return(true)
      controller.stub!(:current_user).and_return(current_user)
    end
    
    describe 'when asked for the index' do
      it 'should not redirect' do
        get :index
        response.should_not redirect_to(new_user_session_url)
      end
      
      it 'should assign values to the view' do
        Message.stub!(:sent_message_count).and_return(20)
        Message.stub!(:waiting_to_be_sent_count).and_return(2)
        
        get :index
        
        assigns[:sent_message_count].should == 20
        assigns[:waiting_to_be_sent_count].should == 2
      end
    end
    
    describe 'when asked for sent' do
      it 'should assign values to the view' do
        Message.stub!(:sent_by_month_count).and_return(20)
        
        get :sent
        assigns[:sent_by_month_count].should == 20
      end
    end
    
    describe 'when asked for waiting_to_be_sent' do
      it 'should assign values to the view' do
        Message.stub!(:waiting_to_be_sent_by_month_count).and_return(2)
        
        get :waiting_to_be_sent
        assigns[:waiting_to_be_sent_by_month_count].should == 2
      end
    end
    
    describe 'when asked for sent' do
      it 'should assign values to the view' do
        Message.stub!(:memory_stats).and_return("value")
        
        get :stats
        assigns[:memory_stats].should == "value"
      end
    end
    
    describe 'when asked for sent_by_month' do
      it 'should assign values to the view' do
        Message.stub!(:sent_by_constituency).and_return(88)

        get :sent_by_month, :yyyy_mm => '2008_01'
        assigns[:sent_by_constituency].should == 88
      end
    end
  end
  
end
