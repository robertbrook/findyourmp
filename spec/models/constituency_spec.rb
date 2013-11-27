require './spec/spec_helper'

describe Constituency do

  assert_model_has_many :postcodes
  assert_model_has_many :messages

  before do
    @constituency = Constituency.new
    @constituency2 = Constituency.new
  end

  describe 'when asked for find_all_constituency_and_member_matches' do
    before do
      @constituency.name = 'Bethnal Green and Bow'
      @constituency2.name = 'Aldershot Bow'
      @constituency.member_name = ''
      @constituency2.member_name = ''
    end

    it 'should sort constituencies by name' do
      constituencies = [@constituency,@constituency2]
      Constituency.should_receive(:find_all_name_or_member_name_matches).with('Bow').and_return constituencies
      constituencies, members = Constituency.find_all_constituency_and_member_matches('Bow')
      constituencies.should == [@constituency2, @constituency]
    end

    it 'should match case of constituency name' do
      @constituency2.name = 'Aldershotbow'
      constituencies = [@constituency,@constituency2]
      Constituency.should_receive(:find_all_name_or_member_name_matches).with('Bow').and_return constituencies
      constituencies, members = Constituency.find_all_constituency_and_member_matches('Bow')
      constituencies.should == [@constituency]
    end

    it 'should ignore case of search term if not capitalized' do
      @constituency2.name = 'Aldershotbow'
      constituencies = [@constituency,@constituency2]
      Constituency.should_receive(:find_all_name_or_member_name_matches).with('bow').and_return constituencies
      constituencies, members = Constituency.find_all_constituency_and_member_matches('bow')
      constituencies.should == [@constituency2,@constituency]
    end

    it 'should match case of member name if capitalized' do
      @constituency.member_name = 'Ian'
      @constituency2.member_name = 'Sian'
      constituencies = [@constituency,@constituency2]
      Constituency.should_receive(:find_all_name_or_member_name_matches).with('Ian').and_return constituencies
      constituencies, members = Constituency.find_all_constituency_and_member_matches('Ian')
      members.should == [@constituency]
    end

    it 'should not match a hidden member name' do
      @constituency.member_name = 'Ian'
      @constituency2.member_name = 'Sian'
      @constituency.member_visible = false
      Constituency.should_receive(:find_all_name_or_member_name_matches).with('ian').and_return [@constituency2]
      constituencies, members = Constituency.find_all_constituency_and_member_matches('ian')
      members.should == [@constituency2]
    end
  end

  describe 'when asked if member name has changed' do
    it 'should return true if it has' do
      @constituency.member_name = 'old'
      @constituency2.member_name = 'new'
      @constituency.member_attribute_changed?(:member_name, @constituency2).should be_true
    end
    it 'should return false if it hasn\'t' do
      @constituency.member_name = 'old'
      @constituency2.member_name = 'old'
      @constituency.member_attribute_changed?(:member_name, @constituency2).should be_false
    end
  end

  describe 'when asked if member party has changed' do
    it 'should return true if it has' do
      @constituency.member_party = 'old'
      @constituency2.member_party = 'new'
      @constituency.member_attribute_changed?(:member_party, @constituency2).should be_true
    end
    it 'should return false if it hasn\'t' do
      @constituency.member_party = 'old'
      @constituency2.member_party = 'old'
      @constituency.member_attribute_changed?(:member_party, @constituency2).should be_false
    end
  end

  describe 'when asked for find_all_name_or_member_name_matches' do
    def should_find_all term
      cleaned_term = term.squeeze(' ').gsub('"','')
      conditions = %Q|name like "%#{cleaned_term}%" or (member_name like "%#{cleaned_term}%" and member_visible = 1)|

      @name_match_lc = mock(Constituency, :name => 'Lanark and Hamilton East', :member_name=>'member')
      @member_match_lc = mock(Constituency, :member_name => 'Ms Emily Thornberry', :name=>'place')
      @name_match = mock(Constituency, :name => 'Milton Keynes South West', :member_name=>'another member')
      @member_match = mock(Constituency, :member_name => 'Anne Milton', :name=>'another place')

      @all_matches = [@name_match_lc, @member_match_lc, @name_match, @member_match]
      Constituency.should_receive(:find).with(:all, :conditions => conditions).and_return @all_matches
    end

    describe 'and search term is lowercase, e.g. "mil"' do
      it 'should return all matches ignoring case' do
        term = 'mil'
        Constituency.case_sensitive(term).should be_false
        should_find_all term
        Constituency.find_all_name_or_member_name_matches(term).should == @all_matches
      end
    end
    describe 'and search term is capitalized, e.g. Mil' do
      it 'should return all matches, case-sensitive' do
        term = 'Mil'
        Constituency.case_sensitive(term).should be_true
        should_find_all term
        Constituency.find_all_name_or_member_name_matches(term).should == [@name_match, @member_match]
      end
    end
    describe 'and search term is in brackets, e.g. "Mil"' do
      it 'should return all matches, case-sensitive' do
        term = '"Mil"'
        Constituency.case_sensitive(term).should be_true
        should_find_all term
        Constituency.find_all_name_or_member_name_matches(term).should == [@name_match, @member_match]
      end
    end
    describe 'and search term is mixedcase, e.g. "MiL"' do
      it 'should return all matches ignoring case' do
        term = 'MiL'
        Constituency.case_sensitive(term).should be_false
        should_find_all term
        Constituency.find_all_name_or_member_name_matches(term).should == @all_matches
      end
    end
  end

  describe 'when asked for find_by_constituency_name' do
    before do
      @match_name = mock(Constituency, :name => 'Aberdeen South', :member_name => 'Miss Anne Begg')
      @match_st = mock(Constituency, :name => 'St. Ives')
      @match_city = mock(Constituency, :name => 'City of York')
      @match_north = mock(Constituency, :name => "Regent's Park and North Kensington")
      @match_the = mock(Constituency, :name => "The Wrekin")
    end

    describe 'and search term is valid' do
      it 'should return a valid constituency' do
        term = 'Aberdeen South'
        Constituency.should_receive(:find_by_name).with(term).and_return @match_name
        Constituency.find_by_constituency_name(term).should == @match_name
      end
    end

    describe 'and search term is St Ives' do
      it 'should search for St. Ives if St Ives produces no results' do
        Constituency.should_receive(:find_by_name).with("St Ives").exactly(2).times.and_return nil
        Constituency.should_receive(:find_by_name).with("St. Ives").and_return @match_st
        Constituency.find_by_constituency_name("St Ives").should == @match_st
      end
    end

    describe 'and search term is York, City of' do
      it 'should return City of York' do
        term = 'York, City of'
        expected = 'City of York'
        Constituency.should_receive(:find_by_name).with(expected).and_return @match_city
        Constituency.find_by_constituency_name(term).name.should == expected
      end
    end

    describe "and search term is Regent's Park & Kensington North" do
      it "should return Regent's Park and North Kensington" do
        term = "Regent's Park & Kensington North"
        expected = "Regent's Park and North Kensington"
        Constituency.should_receive(:find_by_name).with(term).and_return nil
        Constituency.should_receive(:find_by_name).with(expected).and_return @match_north
        Constituency.find_by_constituency_name(term).name.should == expected
      end
    end

    describe "and search term is Wrekin, The" do
      it "should return The Wrekin" do
        term = "Wrekin, The"
        expected = "The Wrekin"
        Constituency.should_receive(:find_by_name).with(term).and_return nil
        Constituency.should_receive(:find_by_name).with(expected).and_return @match_the
        Constituency.find_by_constituency_name(term).name.should == expected
      end
    end
  end

  describe 'when asked to load tsv line' do
    def tsv_line email
      %Q|"Islington West"\t"Duncan McCloud"\t"Plaid Cymru"\t"http://biographies.parliament.uk/parliament/default.asp?id=25505"\t"#{email}"\t"http://www.m.co.uk/"|
    end

    def check_update_constituency contact, contact_type
      Constituency.should_receive(:find_by_constituency_name).with('Islington West').and_return @constituency
      @new_constituency = Constituency.new
      Constituency.should_receive(:new).with(@constituency.attributes).and_return @new_constituency
      @new_constituency.should_receive(:member_name=).with('Duncan McCloud')
      @new_constituency.should_receive(:member_party=).with('Plaid Cymru')
      @new_constituency.should_receive(:member_biography_url=).with('http://biographies.parliament.uk/parliament/default.asp?id=25505')
      @new_constituency.should_receive(:member_website=).with('http://www.m.co.uk/')
      @new_constituency.should_receive(contact_type).with(contact.chomp('.'))
      line = tsv_line(contact)
      loaded = Constituency.load_tsv_line(line)
      loaded.should == [@constituency, @new_constituency]
      loaded[1]
    end

    describe 'and constituency exists and tsv line contains broken email/contact url' do
      it 'should update constituency' do
        new_constituency = check_update_constituency 'broken.contact.details', :member_email=
      end
    end
    describe 'and constituency exists and tsv line contains email' do
      it 'should update constituency' do
        check_update_constituency 'example@email.address.', :member_email=
      end
    end
    describe 'and constituency exists and tsv line contains contact url' do
      it 'should update constituency' do
        check_update_constituency 'http://example.contactform.com', :member_requested_contact_url=
      end
      it 'should update constituency when contact url ends in html file' do
        check_update_constituency 'http://www.armp.org.uk/contact.html', :member_requested_contact_url=
      end
    end
    describe 'and constituency doesn\'t already exist' do
      it 'should create new constituency?' do
        Constituency.load_tsv_line tsv_line('example@email.address')
      end
    end
  end

  describe 'when asked for formatted version' do
    before do
      @constituency.stub!(:no_sitting_member?).and_return false
      @constituency.stub!(:friendly_id).and_return "islington-west"
      @constituency.name = "Islington West"
      @constituency.id = 999
      @constituency.ons_id = 999
      @constituency.member_name = "Duncan McCloud"
      @constituency.member_email = "duncan@mccloud.clan"
      @constituency.member_party = "Plaid Cymru"
      @constituency.member_biography_url = "http://biographies.parliament.uk/parliament/default.asp?id=25476"
      @constituency.member_website = "http://mccloud.uk"
    end

    describe 'as tab separated value line' do
      it 'should return tsv line' do
        @constituency.to_tsv_line.should == %Q|"Islington West"\t"Duncan McCloud"\t"Plaid Cymru"\t"http://biographies.parliament.uk/parliament/default.asp?id=25476"\t"duncan@mccloud.clan"\t"http://mccloud.uk"|
      end
    end
    describe 'in json' do
      it 'should create json correctly' do
        @constituency.to_json('localhost', '3000').should == %Q|{"constituency": {"constituency_name": "Islington West", "member_name": "Duncan McCloud", "member_party": "Plaid Cymru", "member_biography_url": "http://biographies.parliament.uk/parliament/default.asp?id=25476", "member_website": "http://mccloud.uk", "uri": "http://localhost:3000/constituencies/islington-west.json" } }|
      end
    end
    describe 'in text' do
      it 'should create text correctly' do
        @constituency.to_text('localhost', '3000').should == %Q|constituency_name: Islington West\nmember_name: Duncan McCloud\nmember_party: Plaid Cymru\nmember_biography_url: http://biographies.parliament.uk/parliament/default.asp?id=25476\nmember_website: http://mccloud.uk\nuri: http://localhost:3000/constituencies/islington-west.txt|
      end
    end
    describe 'in csv' do
      it 'should create csv correctly' do
        @constituency.to_csv('localhost', '3000').should == %Q|constituency_name,member_name,member_party,member_biography_url,member_website,uri\n"Islington West","Duncan McCloud","Plaid Cymru","http://biographies.parliament.uk/parliament/default.asp?id=25476","http://mccloud.uk","http://localhost:3000/constituencies/islington-west.csv"\n|
      end
    end
    describe 'in yaml' do
      it 'should create yaml correctly' do
        @constituency.to_output_yaml('localhost', '3000').should == %Q|---\nconstituency_name: Islington West\nmember_name: Duncan McCloud\nmember_party: Plaid Cymru\nmember_biography_url: http://biographies.parliament.uk/parliament/default.asp?id=25476\nmember_website: http://mccloud.uk\nuri: http://localhost:3000/constituencies/islington-west.yaml|
      end
    end
  end

  describe 'with invalid member_email' do
    it 'should not be valid' do
      @constituency.member_email = 'bad_email'
      @constituency.valid?.should be_false
    end
  end

  describe 'with valid member_email' do
    before do
      @constituency.member_email = 'ds@example.u.p.co.uk'
    end
    it 'should be valid' do
      @constituency.valid?.should be_true
    end
    describe 'and with member_name' do
      before do
        @constituency.member_name = 'name'
      end
      it 'should have show_message_form? return true' do
        @constituency.show_message_form?.should be_true
      end
      describe 'and with member requested contact url' do
        before do
          @constituency.member_requested_contact_url = 'http://here.co.uk/'
        end
        it 'should have show_message_form? return false' do
          @constituency.show_message_form?.should be_false
        end
      end
    end
    describe 'and without member_name' do
      it 'should have show_message_form? return true' do
        @constituency.show_message_form?.should be_false
      end
    end
  end

  describe 'with member' do
    before do
      @member_name = 'Tiberius Kirk'
      @constituency.member_name = @member_name
      @constituency.member_visible = true
    end
    describe 'when asked for member name' do
      it 'should return member\'s name' do
        @constituency.member_name.should == @member_name
      end
      it 'should have no_sitting_member? return false' do
        @constituency.no_sitting_member?.should be_false
      end
    end
  end

  describe 'vacant' do
    describe 'when asked for member name' do
      it 'should return nil' do
        @constituency.member_name.should be_nil
      end
      it 'should have no_sitting_member? return true' do
         @constituency.no_sitting_member?.should be_true
      end
    end
  end

  describe 'id is 1' do
    before do; @constituency.stub!(:ons_id).and_return "1"; end
    describe 'when asked for code' do
      it 'should return 001' do
        @constituency.code.should == '001'
      end
    end
  end

  describe 'id is 10' do
    before do; @constituency.stub!(:ons_id).and_return "10"; end
    describe 'when asked for code' do
      it 'should return 010' do
        @constituency.code.should == '010'
      end
    end
  end

  describe 'id is 100' do
    before do; @constituency.stub!(:ons_id).and_return "100"; end
    describe 'when asked for code' do
      it 'should return 100' do
        @constituency.code.should == '100'
      end
    end
  end
end
