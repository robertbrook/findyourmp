require File.dirname(__FILE__) + '/../spec_helper'

describe Postcode do

  assert_model_belongs_to :constituency

  before do
    @postcode = Postcode.new
    @constituency_name = 'Islington South'
    @member_name = 'Edmund Husserl'
    @constituency = mock_model(Constituency, :id => 123, :ons_id =>801, :name => @constituency_name, :member_name => @member_name)
    @other_constituency = mock_model(Constituency, :id => 124)
    @postcode.stub!(:constituency).and_return @constituency
    @postcode.stub!(:constituency_id).and_return @constituency.id
    @postcode.stub!(:ons_id).and_return @constituency.ons_id
  end
  
  describe 'when asked to blacklist a postcode' do
    before do
      @code = 'N12SD'
      @postcode.stub!(:code).and_return @code
      @blacklisted = mock_model(BlacklistedPostcode)
    end
    
    describe 'and the postcode has not already been blacklisted' do
      before do
        BlacklistedPostcode.should_receive(:find_by_code).with(@code).and_return nil
        BlacklistedPostcode.should_receive(:new).and_return @blacklisted
      end
      
      it 'should create an entry in the blacklisted_postcodes table and delete the postcodes entry' do
        @blacklisted.stub!(:save).and_return true
        @postcode.should_receive(:delete).and_return true

        @postcode.blacklist.should be_true
      end
      
      it 'should not delete the postcode if there is a problem creating the blacklist entry' do
        @blacklisted.stub!(:save).and_return false
        @postcode.should_not_receive(:delete)
        
        @postcode.blacklist
      end
    end
    
    describe 'and the postcode has already been blacklisted' do
      it 'should delete the postcodes entry' do
        @blacklisted.stub!(:save).and_return true
        BlacklistedPostcode.should_receive(:find_by_code).with(@code).and_return @blacklisted
        @postcode.should_receive(:delete).and_return true

        @postcode.blacklist.should be_true
      end
    end
  end

  describe 'when asked if in constituency' do
    it 'should return true if in given constituency' do
      @postcode.in_constituency?(@constituency).should be_true
    end
    it 'should return false if not in given constituency' do
      @postcode.in_constituency?(@other_constituency).should be_false
    end
  end
  
  describe 'when asked to find postcode by code' do
    it 'should return match including its constituency and member' do
      code = 'N12SD'
      Postcode.should_receive(:find_by_code).with(code, :include => :constituency).and_return @postcode
      Postcode.find_postcode_by_code(code).should == @postcode
    end
    it 'should return nil if given nil code' do
      Postcode.find_postcode_by_code(nil).should be_nil
    end
  end
  
  describe 'when asked for formatted version' do
    before do
      @postcode.stub!(:code).and_return 'N12SD'
    end

    describe 'in json' do
      it 'should create json correctly' do
        @postcode.to_json.should == %Q|{"postcode": {"code": "N1 2SD", "constituency_name": "Islington South", "member_name": "Edmund Husserl", "uri": "http://localhost:3000/postcodes/N12SD.json"} }|
      end
    end
    describe 'in text' do
      it 'should create text correctly' do
        @postcode.to_text.should == %Q|postcode: N1 2SD\nconstituency_name: Islington South\nmember_name: Edmund Husserl\nuri: http://localhost:3000/postcodes/N12SD.txt\n|
      end
    end
    describe 'in csv' do
      it 'should create csv correctly' do
        @postcode.to_csv.should == %Q|postcode,constituency_name,member_name,uri\n"N1 2SD","Islington South","Edmund Husserl","http://localhost:3000/postcodes/N12SD.csv"\n|
      end
    end
    describe 'in yaml' do
      it 'should create yaml correctly' do
        @postcode.to_output_yaml.should == %Q|---\npostcode: N1 2SD\nconstituency_name: Islington South\nmember_name: Edmund Husserl\nuri: http://localhost:3000/postcodes/N12SD.yaml\n|
      end
    end
  end
  
  describe 'when asked for postcode' do
    describe 'with 5 digit postcode' do
      it 'should return postcode with space in right place' do
        @postcode.stub!(:code).and_return 'N12SD'
        @postcode.code_with_space.should == 'N1 2SD'
      end
    end
    
    describe 'with 6 digit postcode' do
      it 'should return postcode with space in right place' do
        @postcode.stub!(:code).and_return 'SW12SD'
        @postcode.code_with_space.should == 'SW1 2SD'
      end
    end
    
    describe 'with 7 digit postcode' do
      it 'should return postcode with space in right place' do
        @postcode.stub!(:code).and_return 'WD257BG'
        @postcode.code_with_space.should == 'WD25 7BG'
      end
    end
  end
  
  describe 'with constituency' do
    describe 'when asked for constituency name' do
      it 'should return constituency name' do
        @postcode.constituency_name.should == @constituency_name
      end
    end
    
    describe 'and member is in constituency' do
      describe 'when asked for member name' do
        it 'should return member name' do
          @postcode.member_name.should == @member_name
        end
      end
    end
    
    describe 'and constituency is vacant' do
      before do
        @constituency.stub!(:member_name).and_return nil
      end
      describe 'when asked for member name' do
        it 'should return nil' do
          @postcode.member_name.should be_nil
        end
      end
    end
  end
end
