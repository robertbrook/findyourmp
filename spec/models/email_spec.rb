require File.dirname(__FILE__) + '/../spec_helper'

describe Email do

  describe 'when asked for all_waiting_to_be_sent' do
    it 'should return all emails sorted by id' do
      Email.should_receive(:count).and_return 2
      Email.waiting_to_be_sent_count.should == 2
    end
  end

end
