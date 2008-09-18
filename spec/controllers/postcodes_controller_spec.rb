require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodesController do

  before do
    @postcode = ' N1  1aA '
    @canonical_postcode = @postcode.upcase.tr(' ','')
    @constituency_id = 801
    @constituency_name = 'Islington South'
    constituency = mock_model(Constituency, :name => @constituency_name)
    @json = '{json : {}}'
    @xml = '<xml/>'

    @postcode_record = mock_model(Postcode, :constituency_id => @constituency_id,
        :code => @canonical_postcode, :constituency => constituency,
        :to_xml => @xml, :to_json => @json)
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

  describe "when finding route for action" do
    it 'should find index root' do
      route_for(:controller => "postcodes", :action => "index").should == "/"
      params_from(:get, "/").should == {:controller => "postcodes", :action => "index"}
    end
    it 'should find show action' do
      route_for(:controller => "postcodes", :action => "show", :postcode=>@canonical_postcode).should == "/postcodes/#{@canonical_postcode}"
      params_from(:get, "/postcodes/#{@canonical_postcode}").should == {:controller => "postcodes", :action => "show", :postcode=>@canonical_postcode}
    end
    it 'should find show action with json format' do
      route_for(:controller => "postcodes", :action => "show", :postcode=>@canonical_postcode, :format => 'json').should == "/postcodes/#{@canonical_postcode}.json"
      params_from(:get, "/postcodes/#{@canonical_postcode}.json").should == {:controller => "postcodes", :action => "show", :postcode=>@canonical_postcode, :format=>'json'}
    end
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

  describe "when asked for constituency given a postcode" do
    def do_get
      get :index, :postcode => @postcode
    end

    get_request_should_be_successful

    describe 'and no matching postcode found' do
      it 'should state no consituency_id found' do
        do_get
        response.body.should == "no constituency_id found for: #{@postcode.squeeze(' ').strip}"
      end
    end

    describe 'and a matching postcode found' do
      it 'should show consituency_id for postcode' do
        Postcode.should_receive(:find_by_code).with(@canonical_postcode).and_return @postcode_record
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

    describe 'and a matching postcode found' do
      before do
        Postcode.should_receive(:find_by_code).with(@canonical_postcode).and_return @postcode_record
      end
      should_render_template 'show'

      it 'should assign postcode to view' do
        do_get
        assigns[:postcode].should == @postcode_record
      end
      it 'should return html format' do
        do_get
        response.content_type.should == "text/html"
      end
      it 'should return xml format' do
        do_get 'xml'
        response.content_type.should == "application/xml"
        response.body.should == @xml
      end
      it 'should return json format' do
        do_get 'json'
        response.content_type.should == "application/json"
        response.body.should == @json
      end
      it 'should return text format' do
        do_get 'text'
        response.content_type.should == "text/plain"
        response.body.should == "postcode: #{@canonical_postcode}\nconstituency_id: #{@constituency_id}\nconstituency: #{@constituency_name}"
      end
    end
    describe 'and a matching postcode not found' do
      it 'should redirect to index search form' do
        do_get
        response.should redirect_to(:action=>'index')
      end
    end
  end
end
