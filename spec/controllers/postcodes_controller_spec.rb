require File.dirname(__FILE__) + '/../spec_helper'

describe PostcodesController do

  before do
    @postcode = ' N1  1aA '
    @canonical_postcode = @postcode.upcase.tr(' ','')
    @constituency_id = 801
    @postcode_record = mock(Postcode, :constituency_id => @constituency_id, :code => @canonical_postcode)
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
  end

  describe "when asked for home page" do
    def do_get
      get :index
    end
    get_request_should_be_successful
    should_render_template 'index'
  end

  describe "when asked for constituency given a postcode" do
    before do
      Postcode.stub!(:find_by_code).and_return nil
    end

    def do_get
      get :index, :postcode => @postcode
    end

    get_request_should_be_successful

    describe 'and no matching postcode found' do
      it 'should state no consituency_id found' do
        Postcode.should_receive(:find_by_code).with(@canonical_postcode).and_return nil
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
    def do_get
      get :show, :postcode => @canonical_postcode
    end

    describe 'and a matching postcode found' do
      it 'should return consituency_id' do
        Postcode.should_receive(:find_by_code).with(@canonical_postcode).and_return @postcode_record
        do_get
        response.body.should == "constituency_id: #{@constituency_id}"
      end
    end
  end
end
