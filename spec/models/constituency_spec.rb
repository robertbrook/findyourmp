require File.dirname(__FILE__) + '/../spec_helper'

describe Constituency do

  assert_model_has_many :postcodes
  assert_model_has_many :messages

  before do
    @constituency = Constituency.new
  end

  describe 'when asked for find_all_name_or_member_name_matches' do
    def should_find_all term
      conditions = %Q|name like "%#{term.squeeze(' ')}%" or member_name like "%#{term.squeeze(' ')}%"|

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
    describe 'and search term is capitalized, e.g. "Mil"' do
      it 'should return all matches, case-sensitive' do
        term = 'Mil'
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

  describe 'with member' do
    before do
      @member_name = 'Tiberius Kirk'
      @constituency.stub!(:member_name).and_return @member_name
    end
    describe 'when asked for member name' do
      it 'should return member\'s name' do
        @constituency.member_name.should == @member_name
      end
    end
  end

  describe 'vacant' do
    describe 'when asked for member name' do
      it 'should return nil' do
        @constituency.member_name.should be_nil
      end
    end
  end

  describe 'id is 1' do
    before do; @constituency.stub!(:id).and_return 1; end
    describe 'when asked for code' do
      it 'should return 001' do
        @constituency.code.should == '001'
      end
    end
  end

  describe 'id is 10' do
    before do; @constituency.stub!(:id).and_return 10; end
    describe 'when asked for code' do
      it 'should return 010' do
        @constituency.code.should == '010'
      end
    end
  end

  describe 'id is 100' do
    before do; @constituency.stub!(:id).and_return 100; end
    describe 'when asked for code' do
      it 'should return 100' do
        @constituency.code.should == '100'
      end
    end
  end
end
