require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodesController do

  def self.get_request_should_be_successful
    eval %Q|    it "should be successful" do
      do_get
      response.should be_success
    end|
  end

  def self.should_render_template template_name
    eval %Q|    it "should render #{template_name} template" do
      do_get
      response.should render_template('#{template_name}')
    end|
  end

  describe "when finding route for action" do
    it 'should find index root' do
      route_for(:controller => "postcodes", :action => "index").should == "/"
      params_from(:get, "/").should == {:controller => "postcodes", :action => "index"}
    end
    it 'should find constituency route' do
      route_for(:controller => "postcodes", :action => "constituency", :postcode=>'N1 1AA').should == "/N1%201AA"
      params_from(:get, "/N1 1AA").should == {:controller => "postcodes", :action => "constituency", :postcode=>'N1 1AA'}
    end
  end

  describe "when asked for home page" do
    def do_get
      get :index
    end
    get_request_should_be_successful
    should_render_template 'index'
  end

end
