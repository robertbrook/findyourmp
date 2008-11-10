class MessagesController < ResourceController::Base

  belongs_to :constituency

  before_filter :redirect_if_not_admin, :except => ['new']

  def redirect_if_not_admin
    unless is_admin?
      redirect_to :controller => 'postcodes', :action => 'index'
    end
  end

end
