require File.dirname(__FILE__) + '/../spec_helper'

describe ConstituencyList do

  describe 'when asked for constituencies' do
    before do
      @header = "Constituency	Member	Party"
      @line_1 = %Q|"Islington West"\t"Duncan McCloud"\t"(SDP)"|
      @line_2 = %Q|"Aberdeen North"	"Doran, Mr Frank"	"(Lab)"|
      @line_3 = %Q|"Aberdeen Centre"	"Doran, Frank"	"(Lab)"|
      @items = "#{@header}
#{@line_1}
#{@line_2}
#{@line_3}"
      @constituency_1 = mock(Constituency, :name =>'Islington West')
      @constituency_2 = mock(Constituency, :name =>'Aberdeen North')
      @constituency_3 = mock(Constituency, :name =>'Aberdeen North')
      @constituency_4 = mock(Constituency, :name=>'Westminster')

      Constituency.stub!(:all).and_return [@constituency_1, @constituency_2, @constituency_4]

      Constituency.should_not_receive(:load_tsv_line).with(@header)
      Constituency.should_receive(:load_tsv_line).with(@line_1).and_return [@constituency_1, nil]
      Constituency.should_receive(:load_tsv_line).with(@line_2).and_return [@constituency_2, @constituency_3]
      Constituency.should_receive(:load_tsv_line).with(@line_3).and_return nil
    end

    it 'should create constituencies' do
      list = ConstituencyList.new
      list.items = @items
      constituencies = list.constituencies
      constituencies.size.should == 3
      constituencies.should have_key(@line_1)
      constituencies.should have_key(@line_2)
      constituencies.should have_key(@line_3)
      constituencies[@line_1].should == [@constituency_1, nil]
      constituencies[@line_2].should == [@constituency_2, @constituency_3]
      constituencies[@line_3].should == nil

      constituencies.keys.first.should == @line_3
    end

    it 'should return unchanged constituencies correctly' do
      list = ConstituencyList.new
      list.items = @items
      list.unchanged_constituencies.should == [[@line_1,[@constituency_1, nil]]]
    end
    it 'should return changed constituencies correctly' do
      list = ConstituencyList.new
      list.items = @items
      list.changed_constituencies.should == [[@line_2,[@constituency_2, @constituency_3]]]
    end
    it 'should return unrecognized constituencies correctly' do
      list = ConstituencyList.new
      list.items = @items
      list.unrecognized_constituencies.should == [[@line_3,nil]]
    end
    it 'should return ommitted constituencies correctly' do
      list = ConstituencyList.new
      list.items = @items
      list.ommitted_constituencies.should == [@constituency_4]
    end
  end
end
