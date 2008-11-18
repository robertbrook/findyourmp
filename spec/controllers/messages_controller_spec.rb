require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before do
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @member_name = 'Hon Biggens'
    @message = mock('message')
    collection = mock('array', :build=>@message)
    @constituency = mock_model(Constituency, :name => @constituency_name, :id => @constituency_id, :member_name => @member_name, :messages=>collection)
  end

  describe 'when asked for new message' do
    def do_get
      get :new, :constituency_id => @constituency_id
    end
    before do
      Constituency.stub!(:find).and_return @constituency
    end
    it 'should keep :postcode in flash memory' do
      flash = mock('flash')
      @controller.stub!(:flash).and_return flash
      flash.should_receive(:keep).with(:postcode)
      flash.stub!(:sweep)
      do_get
    end
  end

end
