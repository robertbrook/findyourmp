require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  describe "when finding route for action" do
    it 'should display page not found for unknown routes' do
      params_from(:get, "/bad_url").should == {:controller => "application", :action => "render_not_found", :bad_route=>['bad_url']}
    end
  end

end
