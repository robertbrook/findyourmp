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
  end

  def redirect_to_show_constituency_view
    redirect_to("constituencies/#{@constituency_id}")
  end

  describe 'when asked for messages index' do
    it 'should redirect to constituency view' do
      get :index, :constituency_id => @constituency_id
      response.should redirect_to_show_constituency_view
    end
  end

  describe 'when asked for new message' do
    def do_get
      get :new, :constituency_id => @constituency_id
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
      @message.should_receive(:save).and_return true
      do_post
      response.should redirect_to(constituency_message_url(@constituency_id,@message_id))
    end 
    
    describe 'with an authenticity_token and a message parameter' do
      before do
        @controller.should_receive(:authenticity_token).any_number_of_times.and_return @authenticity_token
        Message.stub!(:new).and_return @message
        @message.should_receive(:save).and_return true
        @message.should_receive(:[]=).with("authenticity_token", @authenticity_token)
      end
      def do_post
        post :create, :constituency_id => @constituency_id, :authenticity_token => @authenticity_token, :message => @message, :model => {}
      end    
      it 'should redirect to show view' do
        do_post
        response.should redirect_to(constituency_message_url(@constituency_id,@message_id))
      end
      it 'should copy the authenticity_token to flash memory' do
        flash = mock('flash')
        @controller.stub!(:flash).and_return flash
        flash.should_receive(:[]=).with('authenticity_token', @authenticity_token)
        flash.should_receive(:[]=).with(:notice, "Successfully created!")
        flash.stub!(:sweep)
        do_post
      end
    end
    
  end

  def handle_authentication_filter token
    @controller.should_receive(:authenticity_token).any_number_of_times.and_return token
    @message.stub!(:sent).and_return false
    @constituency.messages.should_receive(:find).with(@message_id).any_number_of_times.and_return(@message)
    Message.should_receive(:find_by_constituency_id_and_id).with(@constituency_id, @message_id).and_return @message
  end

  describe 'when posted message sent set to true' do
    def do_post token
      handle_authentication_filter token
      @message.should_receive(:authenticate).with(@authenticity_token).and_return true
      post :update, {:constituency_id => @constituency_id, :id => @message_id, :message => {:sent => '1'}}
    end

    it 'should set deliver message' do
      @message.should_receive(:deliver)
      do_post @authenticity_token
    end
    it 'should set flash[:message_sent] to true' do
      @message.stub!(:deliver)
      do_post @authenticity_token
      flash[:message_sent].should be_true
    end
    it 'should redirect to show action' do
      @message.stub!(:deliver)
      do_post @authenticity_token
      response.should redirect_to(constituency_message_url(@constituency_id,@message_id))
    end
  end

  describe 'when asked to edit a message' do
    before do
      Constituency.stub!(:find).and_return @constituency
      @flash = mock('flash')
      @controller.stub!(:flash).and_return @flash
      @flash.stub!(:sweep)
      @flash.stub!(:keep)
    end
    
    def do_get token, message_id
      handle_authentication_filter token
      get :edit, :constituency_id => @constituency_id, :id => message_id, :authenticity_token => token
    end

    describe 'and authenticity_token matches' do
      it 'should redirect to edit' do
        @flash.should_receive(:[]=).with("authenticity_token", @authenticity_token)
        @message.should_receive(:authenticate).with(@authenticity_token).and_return true
        
        do_get @authenticity_token, @message_id
        response.should redirect_to(constituency_message_url(@constituency_id,@message_id) +'/edit')
      end
    end
    
    describe 'without an authenticity_token being passed' do
      it 'should keep "authenticity_token" in flash memory' do
        handle_authentication_filter @authenticity_token
        @message.should_receive(:authenticate).with(@authenticity_token).and_return true
                
         @flash.should_receive(:keep).with('authenticity_token')
        
        get :edit, :constituency_id => @constituency_id, :id => @message_id
      end
    end
    
    describe 'and message doesn\'t exist' do
      it 'should respond with Not Found' do
        @controller.should_receive(:authenticity_token).any_number_of_times.and_return @authenticity_token
        @constituency.messages.should_receive(:find).with(@message_id).any_number_of_times.and_return(nil)
        Message.should_receive(:find_by_constituency_id_and_id).with(@constituency_id, @message_id).and_return nil

        get :edit, :constituency_id => @constituency_id, :id => @message_id, :authenticity_token => @authenticity_token

        response.status.should == '404 Not Found'
      end
    end
    
    describe 'and message already sent' do
      it 'should respond with Not Found' do
        @controller.should_receive(:authenticity_token).any_number_of_times.and_return @authenticity_token
        @constituency.messages.should_receive(:find).with(@message_id).any_number_of_times.and_return(@message)
        @message.stub!(:sent).and_return true

        Message.should_receive(:find_by_constituency_id_and_id).with(@constituency_id, @message_id).and_return @message
        @flash.should_receive(:[]).with(:message_sent).and_return nil

        get :edit, :constituency_id => @constituency_id, :id => @message_id, :authenticity_token => @authenticity_token

        response.status.should == '404 Not Found'
      end
    end
  end

  describe 'when asked to destroy a message' do
    it 'should respond with Not Found' do
      Constituency.stub!(:find).and_return @constituency
      @controller.should_receive(:authenticity_token).any_number_of_times.and_return @authenticity_token
      @constituency.messages.should_receive(:find).with(@message_id).any_number_of_times.and_return(@message)
      @message.stub!(:sent).and_return false
      Message.should_receive(:find_by_constituency_id_and_id).with(@constituency_id, @message_id).and_return @message
      @message.should_receive(:authenticate).with(@authenticity_token).and_return true
      
      get :destroy, :constituency_id => @constituency_id, :id => @message_id
      response.status.should == '404 Not Found'
    end
  end
  
  describe 'when asked to show a message' do
    def do_get token
      handle_authentication_filter token
      get :show, :constituency_id => @constituency_id, :id => @message_id
    end
    describe 'and authenticity_token matches' do
      it 'should show view' do
        @message.stub!(:sent).and_return false
        @message.should_receive(:authenticate).with(@authenticity_token).and_return true
        do_get @authenticity_token
        response.should be_success
      end
    end
    describe 'and authenticity_token doesn\'t match' do
      it 'should redirect to index' do
        bad_token = 'bad_token'
        @message.should_receive(:authenticate).with(bad_token).and_return false
        do_get bad_token
        response.status.should == '404 Not Found'
      end
    end
  end
end
