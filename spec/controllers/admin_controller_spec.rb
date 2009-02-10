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

end
