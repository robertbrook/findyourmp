require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  shared_examples_for "returns in correct format" do
    it 'should return xml when passed format=xml' do
      do_get 'xml'
      response.content_type.should == "application/xml"
    end

    it 'should return json when passed format=json' do
      do_get 'json'
      response.content_type.should == "application/json"
    end

    it 'should return text when passed format=text' do
      do_get 'text'
      response.content_type.should == "text/plain"
    end

    it 'should return csv when passed format=csv' do
      do_get 'csv'
      response.content_type.should =='text/csv'
    end

    it 'should return yaml when passed format=yaml' do
      do_get 'yaml'
      response.content_type.should =='application/x-yaml'
    end

  end

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
