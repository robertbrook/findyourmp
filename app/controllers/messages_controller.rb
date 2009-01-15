class MessagesController < ResourceController::Base

  belongs_to :constituency

  before_filter :respond_not_found_if_message_sent_or_bad_authenticity_token, :except => ['new']

  def authenticity_token
    params[:authenticity_token] || flash['authenticity_token']
  end

  def respond_not_found_if_message_sent_or_bad_authenticity_token
    if params[:constituency_id] && params[:id]
      if Constituency.exists?(params[:constituency_id])
        @message = Message.find_by_constituency_id_and_id(params[:constituency_id], params[:id])

        if @message.nil?
          render_not_found

        elsif @message.sent
          show_sent_message = (flash[:message_sent] && params[:action] == 'show')
          render_not_found unless show_sent_message

        elsif !@message.authenticate(authenticity_token)
          render_not_found
        end
      end
    end
  end

  def index
    if request.get?
      redirect_to :controller=>'constituencies', :action=>'show', :id=>params[:constituency_id]
    else
      super
    end
  end

  def new
    if constituency = Constituency.find(params[:constituency_id])
      if constituency.show_message_form?
        super
      else
        redirect_to :controller=>:constituencies, :action=>:show, :id=>params[:constituency_id]
      end
    end
    flash.keep(:postcode)
  end

  def edit
    if params[:authenticity_token]
      flash['authenticity_token'] = params[:authenticity_token]
      redirect_to :action => 'edit'
    else
      flash.keep('authenticity_token')
      super
    end
  end

  def create
    if params['message']
      params['message']['authenticity_token'] = params[:authenticity_token]
      flash['authenticity_token'] = params[:authenticity_token]
    end
    super
  end

  def update
    flash.keep('authenticity_token')
    send_message = params['message'] && params['message']['sent'] == '1'

    if send_message
      @message.deliver
      flash[:message_sent] = true
      redirect_to :action => 'show'
    else
      super
    end
  end
end
