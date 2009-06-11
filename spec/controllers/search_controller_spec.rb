require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do

  before do
    @postcode = ' N1  1aA '
    @postcode_district = 'N1'
    @postcode_with_space = 'N1 1AA'
    @canonical_postcode = @postcode.upcase.tr(' ','')
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @member_name_part = 'Bloggs'
    @constituency_name_short = 'sl'
    @constituency_name = 'Islington South'
    @friendly_constituency_id = 'islington-south'
    @constituency = mock_model(Constituency, :name => @constituency_name,
        :id => @constituency_id,
        :friendly_id => @friendly_constituency_id,
        :has_better_id? => false,
        :member_name => 'Dave Bloggs')
    @other_constituency = mock_model(Constituency, :name => 'Islington East',
        :id => 802,
        :friendly_id => 'islington-east',
        :has_better_id? => false,
        :member_name => 'Jo Bloggs')
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

  describe "when asked for constituency given an exact constituency name" do
    def do_get format=nil
      get :index, :q => @constituency_name, :format => format
    end

    before do
      PostcodeDistrict.should_receive(:find_all_by_district).with(@constituency_name).and_return []
      Postcode.should_receive(:find_postcode_by_code).with(@constituency_name).and_return nil
    end

    describe 'and a matching constituency is not found' do
      it 'should redirect to root page' do
        do_get
        response.should redirect_to("")
      end
      
      it_should_behave_like "returns in correct format"
    end

    describe 'and a matching constituency is found' do
      before do
        Constituency.should_receive(:find_all_name_or_member_name_matches).with(@constituency_name).and_return [@constituency]
      end
      it 'should redirect to constituency view showing constituency' do
        do_get
        response.should redirect_to("constituencies/#{@friendly_constituency_id}")
      end
    end
  end

  describe "when asked for constituency given part of constituency name" do
    def do_get format=nil
      get :index, :q => @constituency_name_part, :format => format
    end

    before do
      Postcode.should_receive(:find_postcode_by_code).with(@constituency_name_part).and_return nil
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
        @matching = [@constituency, @other_constituency]
        Constituency.should_receive(:find_all_name_or_member_name_matches).with(@constituency_name_part).and_return @matching
        Constituency.should_receive(:find_all_constituency_and_member_matches).and_return [@matching, []]
      end

      it 'should show list of matching constituencies' do
        @controller.should_receive(:render).with :template => '/constituencies/show'
        do_get
      end

      it 'should assign search term to view' do
        do_get
        assigns[:last_search_term].should == @constituency_name_part
      end
      
      it_should_behave_like "returns in correct format"
    end
  end

  describe "when asked to search for a term of 2 letters" do
    before do
      Postcode.should_receive(:find_postcode_by_code).with(@constituency_name_short).and_return nil
    end

    def do_get format=nil
      get :index, :q => @constituency_name_short, :format => format
    end

    it 'should store "<p>Sorry: we need more than two letters to search" in flash memory</p>' do
      do_get
      flash[:not_found].should == "<p>Sorry: we need more than two letters to search</p>"
    end

    it 'should redirect to root page' do
      do_get
      response.should redirect_to("")
    end

    it_should_behave_like "returns in correct format"

    it 'should set last_search_term in flash memory' do
      do_get
      flash[:last_search_term].should == @constituency_name_short
    end
  end

  describe "when asked for constituency given a postcode" do
    def do_get format=nil
      get :index, :q => @postcode, :format => format
    end

    describe 'and no matching postcode is found' do
      it 'should redirect to root page' do
        do_get
        response.should redirect_to("")
      end
      
      it_should_behave_like "returns in correct format"
      
      it 'should set last_search_term in flash memory' do
        do_get
        flash[:last_search_term].should == @postcode
      end
    end

    describe 'and a matching postcode is found' do
      before do
        Postcode.should_receive(:find_postcode_by_code).with(@postcode).and_return @postcode_record
      end
      
      it 'should redirect to postcode view showing constituency' do
        do_get
        response.should redirect_to("postcodes/#{@canonical_postcode}")
      end
    end
  end

  describe "when asked to search for a partial postcode" do
    def do_get format=nil
      get :index, :q => @postcode_district, :format => format
    end

    before do
      @matches = [ @district_record ]
      PostcodeDistrict.should_receive(:find_all_by_district).with(@postcode_district).and_return @matches
    end

    it 'should redirect to show with the postcode district' do
      do_get
      response.should redirect_to(:controller => 'postcodes', :action => 'show', :postcode => @postcode_district)
    end
  end

  describe 'when asked to show 2 or more constituencies' do
    before do
      @matching = [[@other_constituency, @constituency], []]
    end

    describe 'and there are constituency matches' do
      before do
        Constituency.should_receive(:find_all_constituency_and_member_matches).with(@constituency_name_part).and_return @matching
      end

      def do_get format=nil
        get :show, :q => @constituency_name_part, :format => format
      end

      it 'should assign search term to view' do
        do_get
        assigns[:last_search_term].should == @constituency_name_part
      end

      it_should_behave_like "returns in correct format"
    end

    describe 'and there are member matches' do
      before do
        matching = [[], [@constituency, @other_constituency]]
        Constituency.should_receive(:find_all_constituency_and_member_matches).with(@member_name_part).and_return matching
      end

      def do_get format=nil
        get :show, :q => @member_name_part, :format => format
      end

      it 'should assign constituencies to view ordered by member_name' do
        do_get
        members_ordered_by_name = [@constituency, @other_constituency]
        assigns[:members].should == members_ordered_by_name
      end

      it 'should assign search term to view' do
        do_get
        assigns[:last_search_term].should == @member_name_part
      end

      it_should_behave_like "returns in correct format"
    end

    describe 'and the search term is all lower case' do
      before do
        Constituency.should_receive(:find_all_constituency_and_member_matches).with('islington').and_return @matching
      end

      def do_get format=nil
        get :show, :q => 'islington', :format => format
      end

      it 'should show list of matching constituencies' do
        do_get
        constituencies_ordered_by_name = [@other_constituency, @constituency]
        assigns[:constituencies].should == constituencies_ordered_by_name
      end
      
      it_should_behave_like "returns in correct format"
    end
  end

  describe 'search route' do
    it 'should route correctly' do
      params_from(:get, "/search?q=E3+2AT&commit=Find+MP").should == {:controller => "search", :action => "index", :q=>'E3+2AT', :commit=>"Find+MP"}
    end
  end

end

