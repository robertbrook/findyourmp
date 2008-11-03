require File.dirname(__FILE__) + '/../spec_helper'

describe ConstituenciesController do

  before do
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @constituency = mock_model(Constituency, :name => @constituency_name, :id => @constituency_id)

    @other_constituency_id = 802
    @other_constituency = mock_model(Constituency, :name => 'Islington North', :id => 802)

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
    end
    it 'should find show action' do
      route_for(:controller => "constituencies", :action => "show", :id=>@two_constituency_ids).should == "/constituencies/#{@two_constituency_ids}"
      params_from(:get, "/constituencies/#{@two_constituency_ids}").should == {:controller => "constituencies", :action => "show", :id=>@two_constituency_ids}
    end
  end

  describe "when asked for one constituency by id along with search term" do
    before do
      Constituency.stub!(:find).and_return @constituency
    end
    def do_get
      get :show, :id => @constituency_id
    end
    it 'should assign is_admin to view' do
      @controller.stub!(:is_admin?).and_return false
      do_get
      assigns[:is_admin].should be_false
    end
    it 'should assign constituency to view' do
      Constituency.should_receive(:find).with(@constituency_id.to_s).and_return @constituency
      do_get
      assigns[:constituency].should == @constituency
    end
  end

  describe "when asked for several constituencies by ids along with search term" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get
      get :show, :id => @two_constituency_ids, :q => @constituency_name_part
    end
    it 'should assign is_admin to view' do
      @controller.stub!(:is_admin?).and_return false
      do_get
      assigns[:is_admin].should be_false
    end
    it 'should assign constituencies to view' do
      Constituency.should_receive(:find_all_by_id).with(["#{@constituency_id}","#{@other_constituency_id}"]).and_return [@constituency, @other_constituency]
      do_get
      assigns[:constituencies].should == [@constituency, @other_constituency]
    end
    it 'should assign search term to view' do
      do_get
      assigns[:search_term].should == @constituency_name_part
    end
  end

end
