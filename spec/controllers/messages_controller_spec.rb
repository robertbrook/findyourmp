require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before do
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @member_name = 'Hon Biggens'
    @message_id = "12"
    @message = mock(Message, :to_param => @message_id)
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

  describe 'when posted a new message' do
    def do_post
      post :create, :constituency_id => @constituency_id, :model => {}
    end
    it 'should redirect to show view' do
      Constituency.stub!(:find).with(@constituency_id.to_s).and_return @constituency
      Message.stub!(:new).and_return @message
      @message.should_receive(:save).and_return true
      do_post
      response.should redirect_to(constituency_message_url("801",@message_id))
    end
  end

  describe 'when asked to show a new message' do
    def do_get
      get :show, :constituency_id => @constituency_id, :id => @message_id
    end
    describe 'and authenticity_token matches' do
      it 'should show view' do
        @constituency.messages.should_receive(:find).with(@message_id).and_return(@message)
        Constituency.stub!(:find).with(@constituency_id.to_s).and_return @constituency
        do_get
      end
    end
  end
end
