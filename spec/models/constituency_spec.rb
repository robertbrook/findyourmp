require File.dirname(__FILE__) + '/../spec_helper'

describe Constituency do

  assert_model_has_many :postcodes

  before do
    @constituency = Constituency.new
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
