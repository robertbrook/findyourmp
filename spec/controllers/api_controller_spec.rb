require File.dirname(__FILE__) + '/../spec_helper'

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
        :has_better_id? => false)

    @other_constituency_id = 802
    @other_constituency = mock_model(Constituency, :name => 'Islington & North', :id => 802, :member_name => 'A Biggens-South')

    @postcode_record = mock_model(Postcode, :constituency_id => @constituency_id,
        :code => @canonical_postcode, :code_with_space => @postcode_with_space, :constituency => @constituency,
        :to_json => @json, :to_text => @text, :to_csv => @csv, :to_output_yaml=>@yaml)
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
        get :search, :search_term => @postcode_no_space, :format => format
      end
    
      it 'should assign postcode to view' do  
        do_get
        assigns[:postcode].should == @postcode_record
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
        response.content_type.should == "text/html"
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'  
        response.content_type.should == "application/xml"
      end
    
      it 'should return text when passed format=text' do
        do_get 'text'  
        response.content_type.should == "text/plain"
      end
    
      it 'should return csv when passed format=csv' do
        do_get 'csv'
        response.content_type.should =='text/csv'
      end
    
      it 'should return csv when passed format=yaml' do
        do_get 'yaml'
        response.content_type.should =='application/x-yaml'
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
        get :search, :search_term => @constituency_name, :format => format
      end
    
      it 'should assign constituency to view' do  
        do_get
        assigns[:constituency].should == @constituency
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
        response.content_type.should == "text/html"
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'  
        response.content_type.should == "application/xml"
      end
    
      it 'should return yaml when passed format=yaml' do
        @constituency.should_receive(:to_output_yaml).and_return "---"
        do_get 'yaml'  
        response.content_type.should == "application/x-yaml"
      end
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
        get :search, :search_term => @constituency_name_part, :format => format
      end
    
      it 'should assign constituency to view' do  
        do_get
        assigns[:constituencies].should == @matches
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
        response.content_type.should == "text/html"
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == "application/xml"
      end
    
      it 'should return yaml when passed format=yaml' do
        @constituency.should_receive(:to_text).and_return "text"
        @other_constituency.should_receive(:to_text).and_return "other text"
        do_get 'yaml'
        response.content_type.should == "application/x-yaml"
      end
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
        get :search, :search_term => 'islington', :format => format
      end
    
      it 'should assign constituency to view' do  
        do_get
        assigns[:constituencies].should == @matches
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
        response.content_type.should == "text/html"
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == "application/xml"
      end
    
      it 'should return yaml when passed format=yaml' do
        @constituency.should_receive(:to_text).and_return "text"
        @other_constituency.should_receive(:to_text).and_return "other text"
        do_get 'yaml'
        response.content_type.should == "application/x-yaml"
      end
    end
    
    describe "when passed a search term which matches a postcode district" do
      before do
        @matches = [ @postcode_record ]
        PostcodeDistrict.should_receive(:find_all_by_district).with(@postcode_district).and_return(@matches)
      end
    
      def do_get format=nil
        get :search, :search_term => @postcode_district, :format => format
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == 'application/xml'
      end
    end

    describe "when passed a search term which returns no results" do
      before do
        Postcode.stub!(:find_postcode_by_code)
        Postcode.should_receive(:find_postcode_by_code).and_return nil
        Constituency.stub!(:find_all_name_or_member_name_matches)
        Constituency.should_receive(:find_all_name_or_member_name_matches).and_return [ ]
      end
    
      def do_get format=nil
        get :search, :search_term => 'invalid', :format => format
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
        response.content_type.should == "text/html"
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'  
        response.content_type.should == "application/xml"
      end

      it 'should return json when passed format=json' do
        do_get 'json'  
        response.content_type.should == "application/json"
      end
    
      it 'should return csv when passed format=csv' do
        do_get 'csv'  
        response.content_type.should == "text/csv"
      end

      it 'should return yaml when passed format=yaml' do
        do_get 'yaml'  
        response.content_type.should == "application/x-yaml"
      end
    
      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should == "<p>Sorry: we couldn't find a constituency or MP when we searched for <code>invalid</code>. If you were searching for a postcode, please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode. If you were looking for a Member you may wish to check the <a href=\"http://www.parliament.uk/directories/hciolists/alms.cfm\">alphabetical list of Members</a> instead.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>"
      end
    
      it 'should store the search term in flash memory' do
        do_get
        flash[:last_search_term].should == 'invalid'
      end
    end

    describe "when passed a search term of 2 characters" do    
      def do_get format=nil
        get :search, :search_term => @constituency_name_short, :format => format
      end
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
        response.content_type.should == "text/html"
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'  
        response.content_type.should == "application/xml"
      end

      it 'should return json when passed format=json' do
        do_get 'json'  
        response.content_type.should == "application/json"
      end
    
      it 'should return csv when passed format=csv' do
        do_get 'csv'  
        response.content_type.should == "text/csv"
      end

      it 'should return yaml when passed format=yaml' do
        do_get 'yaml'  
        response.content_type.should == "application/x-yaml"
      end
    
      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should == "<p>Sorry: we need more than two letters to search</p>"
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
        flash[:not_found].should == "<p>Sorry: the API did not recognise this parameter.</p>"
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
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
    
      it 'should assign postcode to view' do
        do_get
        assigns[:postcode].should == @postcode_record
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == 'application/xml'
      end
    end
  
    describe "when passed an invalid postcode" do
      before do
        Postcode.stub!(:find_postcode_by_code).and_return nil
        Postcode.should_receive(:find_postcode_by_code).with('invalid').and_return nil
      end
      
      def do_get format=nil
        get :postcodes, :code => 'invalid', :format => format
      end
      
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
      
      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should == "<p>Sorry: we couldn't find a postcode when we searched for <code>invalid</code>. Please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>"
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
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == 'application/xml'
      end
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
        flash[:not_found].should == "<p>Sorry: we couldn't find a postcode when we search for <code>invalid</code>. Please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>"
      end
    end
    
    describe "when not passed a valid parameter" do
      def do_get format=nil
        get :postcodes, :format => format
      end
      
      it 'should store an error message in flash memory' do
        do_get
        flash[:not_found].should == "<p>Sorry: the API did not recognise this parameter.</p>"
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
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
    
      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == 'application/xml'
      end
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
        flash[:not_found].should == "<p>Sorry: we couldn't find a constituency with an ONS id of 9999.</p>"
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
    
      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end
    
      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end
    
      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == 'application/xml'
      end
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
        flash[:not_found].should == "<p>Sorry: we couldn't find a constituency with a member name of invalid.</p>"
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

      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end

      it 'should assign constituency to view' do
        do_get
        assigns[:constituency].should == @constituency
      end

      it 'should return xml when passed format=xml' do
        do_get 'xml'
        response.content_type.should == 'application/xml'
      end
    end

    describe "when passed an invalid constituency name" do
      before do
        Constituency.stub!(:find).and_return nil
        Constituency.should_receive(:find).and_return nil
      end

      def do_get format=nil
        get :constituencies, :constituency => 'invalid', :format => format
      end

      it 'should not redirect' do
        do_get
        response.redirect?.should be_false
      end

      it 'should store the error message in flash memory' do
        do_get
        flash[:not_found].should == "<p>Sorry: we couldn't find a constituency with a constituency name of invalid.</p>"
      end
    end
    
    describe "when not passed a valid parameter" do
      def do_get format=nil
        get :constituencies, :format => format
      end
      
      it 'should store an error message in flash memory' do
        do_get
        flash[:not_found].should == "<p>Sorry: the API did not recognise this parameter.</p>"
      end
    end
  end
end