require File.dirname(__FILE__) + '/../spec_helper'

describe ConstituencyList do

  describe 'when asked for constituencies' do
    before do
      @header = "Constituency	Member	Party"
      @line_1 = %Q|"Aberavon"	"Francis, Dr Hywel"	"(Greens)"|
      @line_2 = %Q|"Aberdeen North"	"Doran, Mr Frank"	"(Greens)"|
      @items = "#{@header}
#{@line_1}
#{@line_2}"
      @constituency_1 = mock(Constituency)
      @constituency_2 = mock(Constituency)
    end

    it 'should create constituencies' do
      Constituency.should_not_receive(:load_tsv_line).with(@header)
      Constituency.should_receive(:load_tsv_line).with(@line_1).and_return @constituency_1
      Constituency.should_receive(:load_tsv_line).with(@line_2).and_return @constituency_2

      list = ConstituencyList.new
      list.items = @items

      list.constituencies.size.should == 2
      list.constituencies.should have_key(@line_1)
      list.constituencies.should have_key(@line_2)
      list.constituencies[@line_1].should == @constituency_1
      list.constituencies[@line_2].should == @constituency_2
    end
  end
end
