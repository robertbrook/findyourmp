require './spec/spec_helper'

describe UsersController do
  
  describe "when logged in as admin" do
    before do
      @current_user = mock_model User
      @current_user.stub!(:admin?).and_return(true)
      controller.stub!(:current_user).and_return(@current_user)
      current_user_session = mock_model UserSession
      current_user_session.stub!(:destroy)
      @current_user.stub!(:id).and_return(1)
      controller.stub!(:current_user_session).and_return(current_user_session)
    end
    
    describe 'when asked to create a new user' do
      before do
        @user = mock_model User
        @user.stub!(:save)
        User.stub!(:new).and_return(@user)
      end
    
      it 'should render the :new action if save fails' do
        @controller.should_receive(:render).with :action => :new
        get :create
      end
      
      it 'should store "Account registered!" in flash memory if save succeeds' do
        @user.should_receive(:save).and_return(true)
        get :create 
        flash[:notice].should == "Account registered!"
      end
    end
    
    describe 'when asked to update a user' do
      before do
        @current_user.stub!(:email=)
        @current_user.stub!(:password=)
        @current_user.stub!(:password_confirmation=)
      end
      
      it 'should successfully update the user\'s own account' do
        @current_user.should_receive(:save).and_return(true)
        post :update, :id => 1, :user => {:email => 'test@test.com', :password => 'pass', :password_confirmation => 'pass'}
        
        flash[:notice].should == "Account updated!"
      end
            
      it 'should successfully update another user\'s account' do
        user2 = mock_model User
        
        User.should_receive(:find).with("2").and_return(user2)
        user2.should_receive(:save).and_return(true)
        user2.stub!(:email=)
        user2.stub!(:admin=)
        post :update, :id => 2, :user => {:email => 'test@test.com', :password => 'pass', :password_confirmation => 'pass', :admin => 'false'}
          
        flash[:notice].should == "Account updated!"
      end
      
      it 'should render the :edit view if the save fails' do
        user2 = mock_model User
        
        User.should_receive(:find).with("2").and_return(user2)
        user2.should_receive(:save).and_return(false)
        user2.stub!(:email=)
        user2.stub!(:admin=)
        @controller.should_receive(:render).with(:action => :edit)  
        post :update, :id => 2, :user => {:email => 'test@test.com', :password => 'pass', :password_confirmation => 'pass', :admin => 'false'}      
      end
    end
  
    describe 'when asked for new' do
      it 'should assign a new user to the view' do
        get :new
        assigns[:user].should_not be_nil
      end
    end
        
    describe 'when asked for index' do
      it 'should assign an array of current users to the view' do
        User.stub!(:all).and_return([@current_user])
        get :index
        assigns[:users].should == [@current_user]
      end
    end
  end
  
end