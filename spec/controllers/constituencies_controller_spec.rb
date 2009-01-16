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
    # it 'should find message action' do
      # route_for(:controller => "constituencies", :action => "mail", :id=>@constituency_id).should == "/constituencies/#{@constituency_id}/mail"
      # params_from(:get, "/constituencies/#{@constituency_id}/mail").should == {:controller => "constituencies", :action => "mail", :id=>@constituency_id.to_s}
    # end
  end

  describe "when asked for one constituency by id along with search term" do
    before do
      Constituency.stub!(:find).and_return @constituency
    end
    def do_get
      get :show, :id => @friendly_id
    end
    it 'should assign is_admin to view' do
      @controller.stub!(:is_admin?).and_return false
      do_get
      assigns[:is_admin].should be_false
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

  describe "when asked for several constituencies by ids along with search term that matches constituency names" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get
      get :show, :id => @two_constituency_ids, :search_term => @constituency_name_part
    end
    it 'should assign is_admin to view' do
      @controller.stub!(:is_admin?).and_return false
      do_get
      assigns[:is_admin].should be_false
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
  end

  describe "when asked for several constituencies by ids along with search term that matches member names" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get
      get :show, :id => @two_constituency_ids, :search_term => @member_name_part
    end
    it 'should assign is_admin to view' do
      @controller.stub!(:is_admin?).and_return false
      do_get
      assigns[:is_admin].should be_false
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
  end

  describe "when asked for several constituencies by ids along with search term that matches member and constituency names" do
    before do
      Constituency.stub!(:find_all_by_id).and_return [@constituency, @other_constituency]
    end
    def do_get
      get :show, :id => @two_constituency_ids, :search_term => @search_term
    end
    it 'should assign is_admin to view' do
      @controller.stub!(:is_admin?).and_return false
      do_get
      assigns[:is_admin].should be_false
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
