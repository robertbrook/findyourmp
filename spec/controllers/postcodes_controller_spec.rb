require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodesController do

  before do
    @postcode = ' N1  1aA '
    @postcode_district = 'N1'
    @postcode_with_space = 'N1 1AA'
    @canonical_postcode = @postcode.upcase.tr(' ','')
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name_short = 'sl'
    @constituency_name = 'Islington South'
    @friendly_constituency_id = 'islington-south'
    @constituency = mock_model(Constituency, :name => @constituency_name,
        :id => @constituency_id,
        :friendly_id => @friendly_constituency_id,
        :has_better_id? => false)
    @other_constituency = mock_model(Constituency, :name => 'Islington East',
        :id => 802,
        :friendly_id => 'islington-east',
        :has_better_id? => false)
    @json = '{json : {}}'
    @text = "text:"
    @xml = '<xml/>'
    @csv = 'c,s,v'
    @yaml = '---yaml:'

    @postcode_record = mock_model(Postcode, :constituency_id => @constituency_id,
        :code => @canonical_postcode, :code_with_space => @postcode_with_space, :constituency => @constituency,
        :to_json => @json, :to_text => @text, :to_csv => @csv, :to_output_yaml=>@yaml)

    @district_record = mock_model(PostcodeDistrict, :id => 1234, :friendly_id => @friendly_constituency_id, :constituency => @constituency,
        :constituency_name => @constituency_name, :member_name => @member_name, :district => 'N1')
    @other_district_record = mock_model(PostcodeDistrict, :id => 1123, :friendly_id => 'islington-east',  :constituency => @other_constituency,
        :constituency_name => 'Islington East', :member_name => 'Donal Duck', :district => 'E1')

    Postcode.stub!(:find_postcode_by_code).and_return nil
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
    def do_get
      get :index
    end
    get_request_should_be_successful
    should_render_template 'index'
  end

  describe "when asked to show a postcode district" do
    def do_get format=nil
      get :show, :postcode => @postcode_district, :format => format
    end

    describe 'and a single constituency is found' do
      before do
        @matches = [ @district_record ]
        PostcodeDistrict.should_receive(:find_all_by_district).with(@postcode_district).and_return @matches
      end

      it 'should redirect to the page for the constituency' do
        do_get
        response.should redirect_to(:action=>'show', :controller=>'constituencies', :id=> @friendly_constituency_id)
      end
    end

    describe 'and more than one constituency is found' do
      before do
        @matches = [ @district_record, @other_district_record ]
        PostcodeDistrict.should_receive(:find_all_by_district).with(@postcode_district).and_return @matches
      end

      it 'should assign postcodes to the view' do
        do_get
        assigns[:postcode_districts].should == @matches
      end

      it 'should return xml format' do
        do_get 'xml'
        response.content_type.should == "application/xml"
      end
      it 'should return json format' do
        @constituency.should_receive(:to_json).and_return "stuff"
        @other_constituency.should_receive(:to_json).and_return "stuff"
        do_get 'json'
        response.content_type.should == "application/json"
      end
      it 'should return text format' do
        @constituency.should_receive(:to_text).and_return "stuff"
        @other_constituency.should_receive(:to_text).and_return "stuff"
        do_get 'text'
        response.content_type.should == "text/plain"
      end
      it 'should return csv format' do
        @constituency.should_receive(:to_csv_value).and_return "stuff"
        @other_constituency.should_receive(:to_csv_value).and_return "stuff"
        do_get 'csv'
        response.content_type.should == "text/csv"
      end
      it 'should return yaml format' do
        @constituency.should_receive(:to_text).and_return "stuff"
        @other_constituency.should_receive(:to_text).and_return "stuff"
        do_get 'yaml'
        response.content_type.should == "application/x-yaml"
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

      it 'should render constituency view if there is a constituency for postcode' do
        do_get
        response.should redirect_to("/constituencies/#{@friendly_constituency_id}")
      end

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
        Postcode.should_receive(:find_postcode_by_code).with(@postcode_with_space).and_return @postcode_record
        get :show, :postcode => @postcode_with_space
        response.should redirect_to(:action=>'show', :postcode=> @canonical_postcode)
      end

      describe 'and format requested is js' do
        it 'should redirect to canoncial postcode url with format js' do
          Postcode.should_receive(:find_postcode_by_code).with(@postcode_with_space).and_return @postcode_record
          get :show, :postcode => @postcode_with_space, :format => 'js'
          response.should redirect_to(:action=>'show', :postcode=> @canonical_postcode, :format => 'js')
        end
      end
    end

    describe 'and a matching postcode is not found' do
      it 'should redirect to index search form' do
        do_get
        response.should redirect_to(:action=>'index')
      end
      it 'should return xml if passed format "xml"' do
        do_get 'xml'
        response.content_type.should == "application/xml"
      end
      it 'should set non-matching postcode text as last_search_term in flash memory' do
        do_get
        flash[:last_search_term].should == @canonical_postcode
      end
    end
  end
end
