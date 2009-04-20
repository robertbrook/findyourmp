class MessagesController < ResourceController::Base

  belongs_to :constituency

  before_filter :respond_not_found_if_constituency_doesnt_exist
  before_filter :ensure_current_constituency_url, :only => ['new', 'index']
  before_filter :redirect_when_not_appropriate_to_show_message_form
  before_filter :respond_not_found_if_message_sent_or_bad_authenticity_token, :except => ['new','create']

  def new
    referer = request.env['HTTP_REFERER']
    host = request.env['HTTP_HOST']
    referred_from_our_site = referer && (referer.include?(host) || host == 'www.example.com')
    if referred_from_our_site
      flash.keep(:postcode)
      super
    else
      redirect_to_constituency_view
    end
  end

  def create
    if params['message']
      params['message']['authenticity_token'] = params[:authenticity_token]
      flash['authenticity_token'] = params[:authenticity_token]
      send_message = (params['message']['sent'] == '1')
      params['message'].delete('sent')
    end

    build_object
    load_object
    before :create
    if send_message && @message.save
      after :create
      successful = @message.deliver
      flash[:message_just_sent] = successful
      render :template => 'messages/show'
    elsif !send_message && @message.valid?
      after :create
      render :template => 'messages/show'
    else
      after :create_fails
      set_flash :create_fails
      response_for :create_fails
    end
  end

  def index
    redirect_to_constituency_view
  end

  def edit
    redirect_to_constituency_view
  end

  def show
    redirect_to_constituency_view
  end

  def update
    redirect_to_constituency_view
  end

  def destroy
    render_not_found
  end

  private
    def redirect_to_constituency_view
      redirect_to :controller => :constituencies, :action => :show, :id => params[:constituency_id]
    end

    def respond_not_found_if_constituency_doesnt_exist
      begin
        @constituency = Constituency.find(params[:constituency_id])
      rescue
        render_not_found
      end
    end

    def ensure_current_constituency_url
      redirect_to @constituency, :status => :moved_permanently if @constituency.has_better_id?
    end

    def redirect_when_not_appropriate_to_show_message_form
      redirect_to_constituency_view unless @constituency.show_message_form?
    end

    def respond_not_found_if_message_sent_or_bad_authenticity_token
      if (message_id = params[:id])
        @message = Message.find_by_constituency_id_and_id(@constituency.id, message_id)

        if @message.nil?
          render_not_found

        elsif @message.sent
          show_sent_message = (flash[:message_just_sent] && params[:action] == 'show')
          flash.keep(:message_just_sent)
          render_not_found('Not found or expired page.') unless show_sent_message

        else
          bad_authenticity_token = !@message.authenticate(authenticity_token)
          render_not_found if bad_authenticity_token
        end
      end
    end

    def authenticity_token
      params[:authenticity_token] || flash['authenticity_token']
    end
end
