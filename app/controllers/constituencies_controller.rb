class ConstituenciesController < ResourceController::Base

  before_filter :redirect_if_not_admin

  def redirect_if_not_admin
    unless is_admin?
      redirect_to :controller => 'postcodes', :action => 'index'
    end
  end

end
