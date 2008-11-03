class ConstituenciesController < ResourceController::Base

  before_filter :redirect_if_not_admin, :except => 'show'

  def redirect_if_not_admin
    unless is_admin?
      redirect_to :controller => 'postcodes', :action => 'index'
    end
  end

  def show
    id = params[:id]
    @is_admin = is_admin?
    if id.include? '+'
      @search_term = params[:q]
      @constituencies = Constituency.find_all_by_id(id.split('+'))
    else
      @constituency = Constituency.find(id)
    end
  end
end
