require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do

  describe 'when not logged in' do
    describe 'when asked to destroy' do
      before do
        get :destroy
      end
      
      it 'should store "You must be logged in to access this page" in flash memory' do
        flash[:notice].should == "You must be logged in to access this page"
      end
      
      it 'should redirect to the login page' do
        response.should redirect_to(new_user_session_url)
      end
    end
    
    describe 'when attempting to log in' do
      it 'should create a new user_session when requested' do
        get :new
        assigns[:user_session].should_not be_nil
      end
      
      describe 'when the credentials supplied are not correct' do
        it 'should store an error message in flash memory' do
          get :create
          flash[:notice].should == "Your user name and password combination was not recognized. Please try again."
        end
      end
      
      describe 'when the credentials supplied are correct' do   
        before do
          @user_session = mock_model UserSession
          @user_session.stub!(:find_record)
          UserSession.stub!(:new).and_return(@user_session)
        end
               
        it 'should redirect to the admin page' do          
          @user_session.should_receive(:save).and_return(true)
          get :create
          
          flash[:notice].should == ""
          response.should redirect_to(admin_url)
        end
      end
    end
  end
  
  describe 'when logged in' do
    before do
      current_user = mock_model User
      current_user.stub!(:admin?).and_return(false)
      controller.stub!(:current_user).and_return(current_user)
      current_user_session = mock_model UserSession
      current_user_session.stub!(:destroy)
      controller.stub!(:current_user_session).and_return(current_user_session)
    end
    
    describe 'when asked to destroy' do
      it 'should redirect to root' do
        get :destroy
        response.should redirect_to('/')
      end
    end
    
    describe 'when attempting to log in' do
      it 'should redirect to the admin login page' do
        get :new
        response.should redirect_to(admin_url)
      end
    end
  end
end
