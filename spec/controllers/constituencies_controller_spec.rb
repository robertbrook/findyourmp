require File.dirname(__FILE__) + '/../spec_helper'

describe ConstituenciesController do

  before do
    @postcode_with_space = 'N1 1AA'
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @friendly_id = 'islington-south'
    @member_name_part = 'biggens'
    @search_term = 'south'
    @member_name = 'Hon Biggens'
    @constituency = mock_model(Constituency,
        :name => @constituency_name,
        :id => @constituency_id,
        :member_name => @member_name,
        :friendly_id => @friendly_id,
        :has_better_id? => false)

    @other_constituency_id = 802
    @other_constituency = mock_model(Constituency, :name => 'Islington North', :id => 802, :member_name => 'A Biggens-South')
    @constituency_without_mp = mock_model(Constituency, 
        :name => 'Glenrothes', 
        :id => 835,  
        :friendly_id => 'glenrothes',
        :has_better_id? => false,
        :member_visible => false)
    @constituency_without_mp_id = 835
    @constituency_without_mp_friendly_id = 'glenrothes'
    @two_constituency_ids = "#{@constituency_id}+#{@other_constituency_id}"
  end

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
      route_for(:controller => "constituencies", :action => "index").should == "/constituencies"
      params_from(:get, "/constituencies").should == {:controller => "constituencies", :action => "index"}
    end
    it 'should find show action' do
      route_for(:controller => "constituencies", :action => "show", :id=>@constituency_id).should == "/constituencies/#{@constituency_id}"
      params_from(:get, "/constituencies/#{@constituency_id}").should == {:controller => "constituencies", :action => "show", :id=>"#{@constituency_id}"}

      route_for(:controller => "constituencies", :action => "show", :id=>@friendly_id).should == "/constituencies/#{@friendly_id}"
      params_from(:get, "/constituencies/#{@friendly_id}").should == {:controller => "constituencies", :action => "show", :id=>"#{@friendly_id}"}
    end
    it 'should find show action' do
      route_for(:controller => "constituencies", :action => "show", :id=>@two_constituency_ids).should == "/constituencies/#{@two_constituency_ids}"
      params_from(:get, "/constituencies/#{@two_constituency_ids}").should == {:controller => "constituencies", :action => "show", :id=>@two_constituency_ids}
    end
    # it 'should find message action' do
      # route_for(:controller => "constituencies", :action => "mail", :id=>@constituency_id).should == "/constituencies/#{@constituency_id}/mail"
      # params_from(:get, "/constituencies/#{@constituency_id}/mail").should == {:controller => "constituencies", :action => "mail", :id=>@constituency_id.to_s}
    # end
  end

  describe "when asked for one constituency by wrong id" do
    before do
      Constituency.stub!(:find).and_raise ActiveRecord::RecordNotFound.new("Couldn't find Constituency")
    end
    def do_get
      get :show, :id => @friendly_id
    end
    it 'should respond with file not found' do
      do_get
      response.status.should == '404 Not Found'
    end
  end

  describe "when asked for one constituency by friendly_id along with search term" do
    before do
      Constituency.stub!(:find).and_return @constituency
    end
    def do_get
      get :show, :id => @friendly_id
    end
    it 'should assign constituency to view' do
      Constituency.should_receive(:find).with(@friendly_id).and_return @constituency
      do_get
      assigns[:constituency].should == @constituency
    end
    it 'should keep :postcode in flash memory' do
      flash = mock('flash')
      @controller.stub!(:flash).and_return flash
      flash.should_receive(:keep).with(:postcode)
      flash.stub!(:sweep)
      do_get
    end
  end

  describe "when asked for a constituency by friendly_id which does not have a sitting MP" do
    before do
      Constituency.stub!(:find).and_return @constituency_without_mp
    end
    def do_get format=nil
      if format
        get :show, :id => @constituency_without_mp_friendly_id, :format => format
      else
        get :show, :id => @constituency_without_mp_friendly_id
      end
    end
    it 'should assign constituency to view' do
      Constituency.should_receive(:find).with(@constituency_without_mp_friendly_id).and_return @constituency_without_mp
      do_get
      assigns[:constituency].should == @constituency_without_mp
    end
    it 'should return xml when asked for format XML' do
      Constituency.should_receive(:find).with(@constituency_without_mp_friendly_id).and_return @constituency_without_mp
      do_get 'xml'
      response.content_type.should == 'application/xml'
    end
  end

  describe "when asked for several constituencies by ids along with search term that matches constituency names" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get format=nil
      if format
        get :show, :id => @two_constituency_ids, :search_term => @constituency_name_part, :format => format
      else
        get :show, :id => @two_constituency_ids, :search_term => @constituency_name_part
      end
    end
    it 'should assign constituencies to view ordered by name' do
      Constituency.should_receive(:find_all_by_id).with(["#{@constituency_id}","#{@other_constituency_id}"]).and_return [@constituency, @other_constituency]
      do_get
      constituencies_ordered_by_name = [@other_constituency, @constituency]
      assigns[:constituencies].should == constituencies_ordered_by_name
    end
    it 'should assign search term to view' do
      do_get
      assigns[:last_search_term].should == @constituency_name_part
    end
    it 'should return xml if the requested format is xml' do
      do_get 'xml'
      response.content_type.should == "application/xml"
    end
    it 'should return text if the requested format is text' do
      @other_constituency.should_receive(:to_text).and_return('text')
      @constituency.should_receive(:to_text).and_return('text')
      do_get 'text'
      response.content_type.should == "text/plain"
    end
    it 'should return yaml if the requested format is yaml' do
      @other_constituency.should_receive(:to_text).and_return('text')
      @constituency.should_receive(:to_text).and_return('text')
      do_get 'yaml'
      response.content_type.should == "application/x-yaml"
    end
    it 'should return csv if the requested format is csv' do
      @other_constituency.should_receive(:to_csv_value).and_return('text')
      @constituency.should_receive(:to_csv_value).and_return('text')
      do_get 'csv'
      response.content_type.should == "text/csv"
    end
    it 'should return json if the requested format is json' do
      @other_constituency.should_receive(:to_json).and_return('text')
      @constituency.should_receive(:to_json).and_return('text')
      do_get 'json'
      response.content_type.should == "application/json"
    end
  end
  
  describe "when asked for several constituencies by ids along with search term that matches member names" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get format=nil
      if format
        get :show, :id => @two_constituency_ids, :search_term => @member_name_part, :format => format
      else
        get :show, :id => @two_constituency_ids, :search_term => @member_name_part
      end
    end
    it 'should assign members to view ordered by member_name' do
      Constituency.should_receive(:find_all_by_id).with(["#{@constituency_id}","#{@other_constituency_id}"]).and_return [@constituency, @other_constituency]
      do_get
      members_ordered_by_name = [@other_constituency, @constituency]
      assigns[:members].should == members_ordered_by_name
    end
    it 'should assign search term to view' do
      do_get
      assigns[:last_search_term].should == @member_name_part
    end
    it 'should return xml if the requested format is xml' do
      do_get 'xml'
      response.content_type.should == "application/xml"
    end
    it 'should return text if the requested format is text' do
      @other_constituency.should_receive(:to_text).and_return('text')
      @constituency.should_receive(:to_text).and_return('text')
      do_get 'text'
      response.content_type.should == "text/plain"
    end
    it 'should return yaml if the requested format is yaml' do
      @other_constituency.should_receive(:to_text).and_return('text')
      @constituency.should_receive(:to_text).and_return('text')
      do_get 'yaml'
      response.content_type.should == "application/x-yaml"
    end
    it 'should return csv if the requested format is csv' do
      @other_constituency.should_receive(:to_csv_value).and_return('text')
      @constituency.should_receive(:to_csv_value).and_return('text')
      do_get 'csv'
      response.content_type.should == "text/csv"
    end
    it 'should return json if the requested format is json' do
      @other_constituency.should_receive(:to_json).and_return('text')
      @constituency.should_receive(:to_json).and_return('text')
      do_get 'json'
      response.content_type.should == "application/json"
    end
  end

  describe "when asked for several constituencies by ids along with search term that matches member and constituency names" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get
      get :show, :id => @two_constituency_ids, :search_term => @search_term
    end
    it 'should assign constituencies to view ordered by name' do
      Constituency.should_receive(:find_all_by_id).with(["#{@constituency_id}","#{@other_constituency_id}"]).and_return [@constituency]
      do_get
      constituencies_ordered_by_name = [@constituency]
      assigns[:constituencies].should == constituencies_ordered_by_name
    end
    it 'should assign members to view ordered by member_name' do
      Constituency.should_receive(:find_all_by_id).with(["#{@constituency_id}","#{@other_constituency_id}"]).and_return [@other_constituency]
      do_get
      members_ordered_by_name = [@other_constituency]
      assigns[:members].should == members_ordered_by_name
    end
    it 'should assign search term to view' do
      do_get
      assigns[:last_search_term].should == @search_term
    end
  end

  describe "when on the edit screen" do
    before do
       @controller.stub!(:is_admin?).and_return true
       request.env["HTTP_REFERER"] = "/previous/url"
    end

    describe "and asked to hide_members" do
      it 'should hide the members and return to the previous page' do
        Constituency.should_receive(:all).and_return [ @constituency ]
        @constituency.should_receive(:member_visible).and_return true
        @constituency.should_receive(:member_visible=).with(false)
        @constituency.stub!(:save)
        post :hide_members
        response.should redirect_to('http://test.host/previous/url')
      end
    end

    describe "and asked to unhide_members" do
      it 'should hide the members and return to the previous page' do
        Constituency.should_receive(:all).and_return [ @constituency ]
        @constituency.should_receive(:member_visible).and_return false
        @constituency.should_receive(:member_visible=).with(true)
        @constituency.stub!(:save)
        post :unhide_members
        response.should redirect_to('http://test.host/previous/url')
      end
    end
  end

  # describe "when asked for 'mail to constituency MP' page" do
    # def do_get
      # get :mail, :id => @constituency_id
    # end
#
    # describe 'and constituency is found' do
      # before do
        # Constituency.stub!(:find).and_return @constituency
      # end
#
      # get_request_should_be_successful
      # should_render_template 'mail'
#
      # it 'should find constituency by id' do
        # Constituency.should_receive(:find).with(@constituency_id.to_s).and_return @constituency
        # do_get
      # end
      # it 'should assign constituency to view' do
        # do_get
        # assigns[:constituency].should == @constituency
      # end
      # it 'should assign constituency member_name to view' do
        # do_get
        # assigns[:member_name].should == @member_name
      # end
    # end
  # end
end
