require './spec/spec_helper'

describe ApiController do

  before do
    @postcode_no_space = 'N11AA'
    @postcode = ' N1  1aA '
    @postcode_with_space = 'N1 1AA'
    @postcode_district = 'N1'
    @canonical_postcode = @postcode.upcase.tr(' ','')
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name_short = 'sl'
    @constituency_name = 'Islington South'
    @member_name = 'Mickey Muse'
    @friendly_constituency_id = 'islington-south'

    @constituency = mock_model(Constituency, :name => @constituency_name,
        :id => @constituency_id,
        :member_name => @member_name,
        :friendly_id => @friendly_constituency_id,
        :has_better_id? => false,
        :to_text => 'text version of data',
        :to_csv => 'csv version of data with headers',
        :to_csv_value => 'csv version of data',
        :to_json => '(json version of data)',
        :to_output_yaml => 'yaml version of data')

    @other_constituency_id = 802
    @other_constituency = mock_model(Constituency, :name => 'Islington & North',
      :id => 802,
      :member_name => 'A Biggens-South',
      :to_text => 'text version of data',
      :to_csv_value => 'csv version of data',
      :to_json => '(json version of data)',
      :to_output_yaml => 'yaml version of data')

    @postcode_record = mock_model(Postcode, :constituency_id => @constituency_id,
        :code => @canonical_postcode, :code_with_space => @postcode_with_space, :constituency => @constituency,
        :to_json => @json, :to_text => @text, :to_csv => @csv, :to_output_yaml=>@yaml)
  end

  describe 'non redirecting url', :shared => true do
    it 'should not redirect' do
      do_get
      response.redirect?.should be_false
    end
  end

  describe "when finding route for action" do
    it 'should display page not found for unknown routes' do
      params_from(:get, "/bad_url").should == {:controller => "application", :action => "render_not_found", :bad_route=>['bad_url']}
    end
  end

  describe "the search api" do
    describe "when passed a search_term which matches a postcode" do
      before do
        Postcode.stub!(:find_postcode_by_code).and_return @postcode_record
        Postcode.should_receive(:find_postcode_by_code).with(@postcode_no_space).and_return @postcode_record
      end

      def do_get format=nil
        get :search, :q => @postcode_no_space, :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"

      it 'should render js correctly' do
        do_get 'js'
        response.body.should == %Q|{"results": { "constituencies": [json version of data], "members": [] }} |
      end

      it 'should render js with callback correctly' do
        get :search, :q => @postcode_no_space, :format => 'js', :callback => 'callback_function'
        response.body.should == %Q|callback_function({"results": { "constituencies": [json version of data], "members": [] }} )|
      end
    end

    describe "when passed a search term which matches a single constituency" do
      before do
        Postcode.stub!(:find_postcode_by_code)
        Postcode.should_receive(:find_postcode_by_code).with(@constituency_name).and_return nil
        Constituency.stub!(:find_all_name_or_member_name_matches)
        Constituency.should_receive(:find_all_name_or_member_name_matches).with(@constituency_name).and_return [ @constituency ]
      end

      def do_get format=nil
        get :search, :q => @constituency_name, :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed a search term which matches 2 constituencies" do
      before do
        @matches = [ @constituency, @other_constituency ]
        Postcode.stub!(:find_postcode_by_code)
        Postcode.should_receive(:find_postcode_by_code).with(@constituency_name_part).and_return nil
        Constituency.stub!(:find_all_name_or_member_name_matches)
        Constituency.should_receive(:find_all_name_or_member_name_matches).with(@constituency_name_part).and_return @matches
        @constituency.should_receive(:member_name).and_return('asdf')
        @other_constituency.should_receive(:member_name).and_return('qweq')
      end

      def do_get format=nil
        get :search, :q => @constituency_name_part, :format => format
      end

      it 'should assign constituency to view' do
        do_get
        assigns[:constituencies].should == @matches
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed a search term which matches 2 constituencies and is all lower case" do
      before do
        @matches = [ @constituency, @other_constituency ]
        Postcode.stub!(:find_postcode_by_code)
        Postcode.should_receive(:find_postcode_by_code).with('islington').and_return nil
        Constituency.stub!(:find_all_name_or_member_name_matches)
        Constituency.should_receive(:find_all_name_or_member_name_matches).with('islington').and_return @matches
        @constituency.should_receive(:member_name).and_return('asdf')
        @other_constituency.should_receive(:member_name).and_return('qweq')
      end

      def do_get format=nil
        get :search, :q => 'islington', :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"

      it 'should assign constituency to view' do
        do_get
        assigns[:constituencies].should == @matches
      end
    end

    describe "when passed a search term which matches a postcode district" do
      before do
        @matches = [ @postcode_record ]
        PostcodeDistrict.should_receive(:find_all_by_district).with(@postcode_district).and_return(@matches)
      end

      def do_get format=nil
        get :search, :q => @postcode_district, :format => format
      end
      
      it 'should assign the search term to the view' do
        do_get
        assigns[:search_term].should == @postcode_district
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed a search term which returns no results" do
      before do
        Postcode.stub!(:find_postcode_by_code)
        Postcode.should_receive(:find_postcode_by_code).and_return nil
        Constituency.stub!(:find_all_name_or_member_name_matches)
        Constituency.should_receive(:find_all_name_or_member_name_matches).and_return [ ]
      end

      def do_get format=nil
        get :search, :q => 'invalid', :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end

      it 'should store the search term in flash memory' do
        do_get
        flash[:last_search_term].should == 'invalid'
      end
    end

    describe "when passed a search term of 2 characters" do
      def do_get format=nil
        get :search, :q => @constituency_name_short, :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end

      it 'should store the search term in flash memory' do
        do_get
        flash[:last_search_term].should == @constituency_name_short
      end
    end

    describe "when not passed a search_term parameter" do
      def do_get format=nil
        get :search, :format => format
      end

      it 'should store an error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end

      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
    end
  end

  describe "the postcodes api" do
    describe "when passed a valid postcode" do
      before do
        Postcode.stub!(:find_postcode_by_code).and_return @postcode_record
        Postcode.should_receive(:find_postcode_by_code).with(@postcode_no_space).and_return @postcode_record
      end

      def do_get format=nil
        get :postcodes, :code => @postcode_no_space, :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed an invalid postcode" do
      before do
        Postcode.stub!(:find_postcode_by_code).and_return nil
        Postcode.should_receive(:find_postcode_by_code).with('invalid').and_return nil
      end

      def do_get format=nil
        get :postcodes, :code => 'invalid', :format => format
      end

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end

    describe "when passed a valid postcode_district" do
      before do
        @matches = [ @postcode_record ]
        PostcodeDistrict.should_receive(:find_all_by_district).with(@postcode_district).and_return(@matches)
      end

      def do_get format=nil
        get :postcodes, :district => @postcode_district, :format => format
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed an invalid postcode_district" do
      before do
        PostcodeDistrict.should_receive(:find_all_by_district).with('invalid').and_return([])
      end

      def do_get
        get :postcodes, :district => 'invalid'
      end

      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end

    describe "when not passed a valid parameter" do
      def do_get format=nil
        get :postcodes, :format => format
      end

      it 'should store an error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end
  end

  describe "the constituencies api" do
    describe "when passed a valid ONS id" do
      before do
        Constituency.stub!(:find).and_return @constituency
        Constituency.should_receive(:find).and_return @constituency
      end

      def do_get format=nil
        get :constituencies, :ons_id => '123', :format => format
      end

      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed an invalid ONS id" do
      before do
        Constituency.stub!(:find).and_return nil
        Constituency.should_receive(:find).and_return nil
      end

      def do_get format=nil
        get :constituencies, :ons_id => 9999, :format => format
      end

      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end

    describe "when passed a valid member name" do
      before do
        Constituency.stub!(:find).and_return @constituency
        Constituency.should_receive(:find).and_return @constituency
      end

      def do_get format=nil
        get :constituencies, :member => @member_name, :format => format
      end

      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed an invalid member name" do
      before do
        Constituency.stub!(:find).and_return nil
        Constituency.should_receive(:find).and_return nil
      end

      def do_get format=nil
        get :constituencies, :member => 'invalid', :format => format
      end

      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end

    describe "when passed a valid constituency name" do
      before do
        Constituency.stub!(:find).and_return @constituency
        Constituency.should_receive(:find).and_return @constituency
      end

      def do_get format=nil
        get :constituencies, :constituency => @constituency_name, :format => format
      end

      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end

      it_should_behave_like "returns in correct format"
      it_should_behave_like "non redirecting url"
    end

    describe "when passed an invalid constituency name" do
      before do
        Constituency.stub!(:find).and_return nil
        Constituency.should_receive(:find).and_return nil
      end

      def do_get format=nil
        get :constituencies, :constituency => 'invalid', :format => format
      end

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end

    describe "when not passed a valid parameter" do
      def do_get format=nil
        get :constituencies, :format => format
      end

      it 'should store an error message in flash memory' do
        do_get
        flash[:not_found].should be_nil
      end
    end
  end

end