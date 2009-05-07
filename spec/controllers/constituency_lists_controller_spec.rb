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

end
