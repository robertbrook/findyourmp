require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before do
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @friendly_constituency_id = 'islington-south'
    @member_name = 'Hon Biggens'
    @message_id = "12"
    @authenticity_token = 'gattaca'
    @message = mock(Message, :to_param => @message_id, :authenticity_token => @authenticity_token)
    collection = mock('array', :build=>@message)
    @constituency = mock_model(Constituency, :name => @constituency_name,
        :id => @constituency_id, :member_name => @member_name,
        :member_requested_contact_url => nil,
        :messages=>collection,
        :show_message_form? => true,
        :friendly_id => @friendly_constituency_id,
        :has_better_id? => false)
    Constituency.stub!(:find).with(@constituency_id.to_s).and_return @constituency
    Constituency.stub!(:find).with(@friendly_constituency_id).and_return @constituency
  end

  def redirect_to_show_constituency_view id=@friendly_constituency_id
    redirect_to("constituencies/#{id}")
  end

  describe 'when asked for messages index' do
    it 'should redirect to constituency view' do
      get :index, :constituency_id => @friendly_constituency_id
      response.should redirect_to_show_constituency_view
    end
  end

  describe 'when asked for new message for non-existant constituency' do
    def do_get
      get :new, :constituency_id => 'bad_id'
    end
    it 'should return file not found' do
      do_get
      response.status.should == '404 Not Found'
    end
  end

  describe 'when asked for new message' do
    def do_get
      get :new, :constituency_id => @friendly_constituency_id
    end
    describe 'and constituency has a member email' do
      before do
        @constituency.stub!(:member_email).and_return 'mp@parliament.uk'
        @constituency.stub!(:show_message_form?).and_return true
      end
      it 'should keep :postcode in flash memory' do
        flash = mock('flash')
        @controller.stub!(:flash).and_return flash
        flash.should_receive(:keep).with(:postcode)
        flash.stub!(:sweep)
        do_get
      end

      describe 'and member request contact url is set' do
        it 'should redirect to constituency page' do
          @constituency.stub!(:member_requested_contact_url).and_return 'http://contact.me/'
          @constituency.stub!(:show_message_form?).and_return false
          do_get
          response.should redirect_to_show_constituency_view
        end
      end
    end

    describe 'and constituency does not have a member email' do
      it 'should redirect to constituency page' do
        @constituency.stub!(:member_email).and_return ''
        @constituency.stub!(:show_message_form?).and_return false
        do_get
        response.should redirect_to_show_constituency_view
      end
    end
  end

  describe 'when posted a new message' do
    def do_post
      post :create, :constituency_id => @constituency_id, :model => {}
    end
    it 'should redirect to show view' do
      Message.stub!(:new).and_return @message
      @message.should_receive(:valid?).and_return true
      do_post
      response.should render_template("show")
    end

    describe 'with an authenticity_token and a message parameter' do
      before do
        @controller.should_receive(:authenticity_token).any_number_of_times.and_return @authenticity_token
        Message.stub!(:new).and_return @message
        @message.should_receive(:valid?).and_return true
        @message.should_receive(:[]=).with("authenticity_token", @authenticity_token)
        @message.should_receive(:[]).with('sent').and_return 0
        @message.should_receive(:delete).with('sent')
      end
      def do_post
        post :create, :constituency_id => @constituency_id, :authenticity_token => @authenticity_token, :message => @message, :model => {}
      end
      it 'should redirect to show view' do
        do_post
        response.should render_template("show")
      end
      it 'should copy the authenticity_token to flash memory' do
        flash = mock('flash')
        @controller.stub!(:flash).and_return flash
        flash.should_receive(:[]=).with('authenticity_token', @authenticity_token)
        flash.should_not_receive(:[]=).with(:notice, "Successfully created!")
        flash.stub!(:sweep)
        do_post
      end
    end

  end

  describe 'when posted message sent set to true' do
    def do_post
      @message.should_receive(:save).and_return true
      post :create, {:constituency_id => @constituency_id, :id => @message_id, :message => {:sent => '1'}}
    end

    it 'should set deliver message' do
      @message.should_receive(:deliver).and_return true
      do_post
    end
    it 'should set flash[:message_just_sent] to true' do
      @message.stub!(:deliver).and_return true
      do_post
      flash[:message_just_sent].should be_true
    end
    it 'should redirect to show action' do
      @message.stub!(:deliver).and_return true
      do_post
      response.should render_template('messages/show')
    end
  end

  describe 'when asked to edit a message' do
    it 'should not be able to route request' do
      begin
        get :edit, :constituency_id => @constituency_id, :id => @message_id
      rescue Exception => e
        e.should be_an_instance_of(ActionController::RoutingError)
      end
    end
  end

  describe 'when asked to destroy a message' do
    it 'should not be able to route request' do
      begin
        get :destroy, :constituency_id => @constituency_id, :id => @message_id
      rescue Exception => e
        e.should be_an_instance_of(ActionController::RoutingError)
      end
    end
  end

  describe 'when asked to show a message' do
    it 'should not be able to route request' do
      begin
        get :show, :constituency_id => @constituency_id, :id => @message_id
      rescue Exception => e
        e.should be_an_instance_of(ActionController::RoutingError)
      end
    end
  end
end
