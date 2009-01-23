require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  describe "when finding route for action" do
    it 'should display index' do
      params_from(:get, "/admin").should == {:controller => "admin", :action => "index"}
    end
  end

end
