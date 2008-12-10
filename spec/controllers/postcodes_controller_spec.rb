require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodesController do

  before do
    @postcode = ' N1  1aA '
    @postcode_with_space = 'N1 1AA'
    @canonical_postcode = @postcode.upcase.tr(' ','')
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @constituency = mock_model(Constituency, :name => @constituency_name, :id => @constituency_id)
    @json = '{json : {}}'
    @text = "text:"
    @xml = '<xml/>'
    @csv = 'c,s,v'
    @yaml = '---yaml:'

    @postcode_record = mock_model(Postcode, :constituency_id => @constituency_id,
        :code => @canonical_postcode, :code_with_space => @postcode_with_space, :constituency => @constituency,
        :to_json => @json, :to_text => @text, :to_csv => @csv, :to_output_yaml=>@yaml)
    Postcode.stub!(:find_by_code).and_return nil
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

  def self.should_route_show_action format
    eval %Q|    it 'should find show action with #{format} format' do
      route_for(:controller => "postcodes", :action => "show", :postcode=>'N11AA', :format => '#{format}').should == "/postcodes/N11AA.#{format}"
      params_from(:get, "/postcodes/N11AA.#{format}").should == {:controller => "postcodes", :action => "show", :postcode=>'N11AA', :format=>'#{format}'}
    end|
  end

  describe "when finding route for action" do
    it 'should find index root' do
      route_for(:controller => "postcodes", :action => "index").should == "/"
      params_from(:get, "/").should == {:controller => "postcodes", :action => "index"}
    end
    it 'should find show action' do
      route_for(:controller => "postcodes", :action => "show", :postcode=>@canonical_postcode).should == "/postcodes/#{@canonical_postcode}"
      params_from(:get, "/postcodes/#{@canonical_postcode}").should == {:controller => "postcodes", :action => "show", :postcode=>@canonical_postcode}
    end
    should_route_show_action 'xml'
    should_route_show_action 'json'
    should_route_show_action 'js'
    should_route_show_action 'txt'
    should_route_show_action 'text'
    should_route_show_action 'csv'
    should_route_show_action 'yaml'
  end

  describe "when asked for home page" do
    before do
      @postcode_count = 1700000
      @constituency_count = 646
      Postcode.stub!(:count).and_return @postcode_count
      Constituency.stub!(:count).and_return @constituency_count
    end

    def do_get
      get :index
    end
    get_request_should_be_successful
    should_render_template 'index'

    it 'should assign postcode count to view' do
      do_get
      assigns[:postcode_count].should == @postcode_count
    end
    it 'should assign constituency count to view' do
      do_get
      assigns[:constituency_count].should == @constituency_count
    end
  end

  describe "when asked for constituency given an exact constituency name" do
    def do_get
      get :index, :search_term => @constituency_name
    end

    before do
      Postcode.should_receive(:find_by_code).with(@constituency_name.upcase.tr(' ','')).and_return nil
    end

    describe 'and a matching constituency is not found' do
      it 'should redirect to root page' do
        do_get
        response.should redirect_to("")
      end
    end

    describe 'and a matching constituency is found' do
      before do
        Constituency.should_receive(:find).with(:all, :conditions =>%Q|name like "%#{@constituency_name.upcase}%" or member_name like "%#{@constituency_name.upcase}%"|).and_return [@constituency]
      end
      it 'should redirect to constituency view showing constituency' do
        do_get
        response.should redirect_to("constituencies/#{@constituency.id}")
      end
    end
  end

  describe "when asked for constituency given part of constituency name" do
    def do_get
      get :index, :search_term => @constituency_name_part
    end

    before do
      Postcode.should_receive(:find_by_code).with(@constituency_name_part.upcase.tr(' ','')).and_return nil
    end

    describe 'and a matching constituency is not found' do
      it 'should redirect to root page' do
        do_get
        response.should redirect_to("")
      end
    end

    describe 'and two matching constituencies are found' do
      before do
        @other_constituency = mock_model(Constituency, :name => 'Islington North', :id => 802)
        matching = [@constituency, @other_constituency]
        Constituency.should_receive(:find).with(:all, :conditions => %Q|name like "%#{@constituency_name_part.upcase}%" or member_name like "%#{@constituency_name_part.upcase}%"|).and_return matching
      end
      it 'should show list of matching constituencies' do
        do_get
        response.should redirect_to("constituencies/#{@constituency.id}+#{@other_constituency.id}?search_term=#{@constituency_name_part}")
      end
    end
  end

  describe "when asked for constituency given a postcode" do
    def do_get
      get :index, :search_term => @postcode
    end

    describe 'and no matching postcode is found' do
      it 'should redirect to root page' do
        do_get
        response.should redirect_to("")
      end
      it 'should set last_search_term in flash memory' do
        do_get
        flash[:last_search_term].should == @postcode
      end
    end

    describe 'and a matching postcode is found' do
      before do
        Postcode.should_receive(:find_by_code).with(@canonical_postcode).and_return @postcode_record
      end
      it 'should redirect to postcode view showing constituency' do
        do_get
        response.should redirect_to("postcodes/#{@canonical_postcode}")
      end
    end
  end

  describe "when asked to show postcode" do
    def do_get format=nil
      if format
        get :show, :postcode => @canonical_postcode, :format => format
      else
        get :show, :postcode => @canonical_postcode
      end
    end

    describe 'and a matching postcode is found' do
      before do
        Postcode.should_receive(:find_postcode_by_code).with(@canonical_postcode).and_return @postcode_record
      end
      should_render_template 'show'

      it 'should assign postcode to view' do
        do_get
        assigns[:postcode].should == @postcode_record
      end
      it 'should set postcode in flash memory' do
        do_get
        flash[:postcode].should == @postcode_with_space
      end
      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end
      it 'should return html format' do
        do_get
        response.content_type.should == "text/html"
      end
      it 'should return xml format' do
        do_get 'xml'
        response.content_type.should == "application/xml"
      end
      it 'should return json format' do
        do_get 'json'
        response.content_type.should == "application/json"
        response.body.should == @json
      end
      it 'should return js format' do
        do_get 'js'
        response.content_type.should == "text/javascript"
        response.body.should == @json
      end
      it 'should return text format' do
        do_get 'text'
        response.content_type.should == "text/plain"
        response.body.should == @text
      end
      it 'should return txt format' do
        do_get 'txt'
        response.content_type.should == "text/plain"
        response.body.should == @text
      end
      it 'should return csv format' do
        do_get 'csv'
        response.content_type.should == "text/csv"
        response.body.should == @csv
      end
      it 'should return yaml format' do
        do_get 'yaml'
        response.content_type.should == "application/x-yaml"
        response.body.should == @yaml
      end
    end

    describe 'and postcode matches if space removed' do
      it 'should redirect to canoncial postcode url' do
        Postcode.should_receive(:find_postcode_by_code).with(@postcode_with_space).and_return nil
        Postcode.should_receive(:find_postcode_by_code).with(@canonical_postcode).and_return @postcode_record
        get :show, :postcode => @postcode_with_space
        response.should redirect_to(:action=>'show', :postcode=> @canonical_postcode)
      end
    end

    describe 'and a matching postcode is not found' do
      it 'should redirect to index search form' do
        do_get
        response.should redirect_to(:action=>'index')
      end
      it 'should set non-matching postcode text as last_search_term in flash memory' do
        do_get
        flash[:last_search_term].should == @canonical_postcode
      end
    end
  end
end
