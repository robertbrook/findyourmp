class MessagesController < ResourceController::Base

  protect_from_forgery

  belongs_to :constituency

  # before_filter :redirect_if_not_admin, :except => ['new','create','show','edit']

  def redirect_if_not_admin
    unless is_admin?
      redirect_to :controller => 'postcodes', :action => 'index'
    end
  end

  def new
    super
    flash.keep(:postcode)
  end

  def edit
    if params[:authenticity_token]
      redirect_to :action => 'edit'
    else
      super
    end
  end

end
