class MessagesController < ResourceController::Base

  belongs_to :constituency

  before_filter :respond_not_found_if_message_sent_or_bad_authenticity_token, :except => ['new']

  def authenticity_token
    params[:authenticity_token] || flash['authenticity_token']
  end

  def respond_not_found_if_message_sent_or_bad_authenticity_token
    if params[:constituency_id] && params[:id]
      if Constituency.exists?(params[:constituency_id])
        message = Message.find_by_constituency_id_and_id(params[:constituency_id], params[:id])

        if message.nil?
          render_not_found

        elsif message.sent
          render_not_found unless flash[:message_sent]

        elsif !message.authenticate(authenticity_token)
          render_not_found
        end
      end
    end
  end

  def new
    super
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
    if params['message']
      if params['message']['sent'] == '1'
        flash[:message_sent] = true
      end
    end
    flash.keep('authenticity_token')
    super
  end
end
