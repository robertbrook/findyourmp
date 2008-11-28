class MessagesController < ResourceController::Base

  # protect_from_forgery :secret => 'not_very'

  belongs_to :constituency

  # before_filter :redirect_if_not_admin, :except => ['new','create','show','edit']

  before_filter :redirect_if_message_sent_or_bad_authenticity_token, :except => ['new']

  def redirect_if_not_admin
    unless is_admin?
      redirect_to :controller => 'postcodes', :action => 'index'
    end
  end

  def render_not_found
    render :text=>'not found or expired page', :status=>:not_found
  end

  def flash_authenticity_token
    flash['authenticity_token']
  end

  def redirect_if_message_sent_or_bad_authenticity_token
    if params[:constituency_id] && params[:id]
      if Constituency.exists?(params[:constituency_id])
        message = Message.find_by_constituency_id_and_id(params[:constituency_id], params[:id])
        if !message || message.sent
          unless flash[:message_sent]
            render_not_found
          end
        elsif params[:authenticity_token] && (message.authenticity_token != params[:authenticity_token])
          render_not_found
        elsif flash_authenticity_token && (message.authenticity_token != flash_authenticity_token)
          render_not_found
        elsif flash_authenticity_token == message.authenticity_token
          flash.keep('authenticity_token')
        else
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
    super
  end
end
