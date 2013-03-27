require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordResetsController do
  describe "when asked to create" do
    before do
      @user = mock_model User
    end
    
    it 'should store a suitable message in flash memory if the user is valid' do
      User.stub!(:find_by_email).and_return(@user)
      @user.stub!(:deliver_password_reset_instructions!)
      get :create
      flash[:notice].should == "<p>Instructions to reset your password have been emailed to you. Please check your email.</p>"
    end
    
    it 'should store an error message in flash memory if the user is invalid' do
      User.stub!(:find_by_email).and_return(nil)
      get :create
      flash[:notice].should == "<p>No user was found with that email address</p>"
    end
  end
  
  describe "when asked to update" do
    before do
      @user = mock_model User
      @user.stub!(:password=)
      @user.stub!(:password_confirmation=)
    end
    
    it 'should store "Password successfully updated" in flash memory if the password reset is successful' do
      User.stub!(:find_using_perishable_token).and_return(@user)
      @user.stub!(:save).and_return(true)
      post :update, :id => 1, :user => {:password => 'pass', :password_confirmation => 'pass'}
      
      flash[:notice].should == "Password successfully updated"
    end
    
    it 'should render the :edit view if the password reset is unsuccessful' do
      User.stub!(:find_using_perishable_token).and_return(@user)
      @user.stub!(:save).and_return(false)
      @controller.should_receive(:render).with()
      @controller.should_receive(:render).with(:action => :edit)
      post :update, :id => 1, :user => {:password => 'pass', :password_confirmation => 'pass'}
    end
    
    it 'should store an error message in flash memory if the user cannot be found' do
      User.stub!(:find_using_perishable_token).and_return(nil)
      post :update, :id => 1, :user => {:password => 'pass', :password_confirmation => 'pass'}
      
      flash[:notice].should == "We're sorry, but we could not locate your account. " +
                 "If you are having issues try copying and pasting the URL " +
                 "from your email into your browser or restarting the " +
                 "reset password process."
    end
  end
end
