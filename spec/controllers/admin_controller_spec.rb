require File.dirname(__FILE__) + '/../spec_helper'

describe AdminController do

  describe "when finding route for action" do
    it 'should display index' do
      params_from(:get, "/admin").should == {:controller => "admin", :action => "index"}
    end
  end

  describe 'when not logged in as admin' do
    it 'should return 401 Unauthorized for all requests' do
      get :index
      response.status.should == '401 Unauthorized'
    end
  end

end
