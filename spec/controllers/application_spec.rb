require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  describe "when finding route for action" do
    it 'should display page not found for unknown routes' do
      params_from(:get, "/bad_url").should == {:controller => "application", :action => "render_not_found", :bad_route=>['bad_url']}
    end

    it 'should display messages' do
      params_from(:get, "/messages").should == {:controller => "application", :action => "messages"}
    end
  end

  describe "when posted to toggle admin action" do
    def do_post
      request.env["HTTP_REFERER"] = '/previous/url'
      post :toggle_admin
    end
    it 'should be successful' do
      do_post
      response.should be_redirect
    end
    it "should redirect to previous url if admin true" do
      do_post
      response.should redirect_to('http://test.host/previous/url')
    end
    it "should redirect to root url if admin false" do
      do_post
      do_post
      response.should redirect_to('http://test.host/')
    end
    describe "and session is_admin is nil" do
      it 'should set session is_admin to true' do
        session[:is_admin] = nil
        do_post
        session[:is_admin].should be_true
      end
    end
    describe "and session is_admin is false" do
      it 'should set session is_admin to true' do
        session[:is_admin] = false
        do_post
        session[:is_admin].should be_true
      end
    end
    describe "and session is_admin is true" do
      it 'should set session is_admin to false' do
        session[:is_admin] = true
        do_post
        session[:is_admin].should be_false
      end
    end
  end
end
