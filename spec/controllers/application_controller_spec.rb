require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  describe "when finding route for action" do
    it 'should display page not found for unknown routes' do
      params_from(:get, "/bad_url").should == {:controller => "application", :action => "render_not_found", :bad_route=>['bad_url']}
    end
  end

  describe 'converting date to month year string' do
    it 'should render correctly' do
      Date.new(2009,2,14).to_s(:month_year).should == 'February 2009'
    end
  end
  describe 'converting time to month year string' do
    it 'should render correctly' do
      Date.new(2009,2,14).to_time.to_s(:month_year).should == 'February 2009'      
    end
  end
end
