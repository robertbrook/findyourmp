require File.dirname(__FILE__) + '/../spec_helper'

describe Constituency do

  assert_model_has_many :postcodes
  assert_model_has_one :member

  before do
    @constituency = Constituency.new
  end

  describe 'with member' do
    before do
      @member_name = 'Tiberius Kirk'
      @member = mock_model(Member, :name => @member_name)
      @constituency.stub!(:member).and_return @member
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
end
