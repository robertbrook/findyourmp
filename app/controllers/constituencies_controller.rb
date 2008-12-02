class ConstituenciesController < ResourceController::Base

  before_filter :redirect_if_not_admin, :except => ['show']

  def redirect_if_not_admin
    unless is_admin?
      redirect_to :controller => 'postcodes', :action => 'index'
    end
  end

  def show
    id = params[:id]
    flash.keep(:postcode)
    @is_admin = is_admin?
    if id.include? '+'
      @search_term = params[:search_term]
      @last_search_term = @search_term
      @constituencies = Constituency.find_all_by_id(id.split('+')).sort_by(&:name)
    else
      @constituency = Constituency.find(id)
    end
  end

  def hide_members
    if is_admin? && request.post?
      Constituency.all.each do |constituency|
        if constituency.member_visible
          constituency.member_visible = false
          constituency.save
        end
      end
      redirect_to :back
    end
  end

  def unhide_members
    if is_admin? && request.post?
      Constituency.all.each do |constituency|
        unless constituency.member_visible
          constituency.member_visible = true
          constituency.save
        end
      end
      redirect_to :back
    end
  end
end
