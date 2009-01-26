class ConstituenciesController < ResourceController::Base

  before_filter :respond_unauthorized_if_not_admin, :except => ['show']

  before_filter :ensure_current_constituency_url, :only => :show

  def show
    id = params[:id]
    flash.keep(:postcode)
    @is_admin = is_admin?
    if id.include? '+'
      @search_term = params[:search_term]
      @last_search_term = @search_term

      @constituencies = Constituency.find_all_by_id(id.split('+')).sort_by(&:name)
      @members = @constituencies.sort_by(&:member_name)

      if @search_term[/[A-Z][a-z].*/]
        @constituencies.delete_if { |element| !(element.name.include? @search_term) }
        @members.delete_if { |element| !(element.member_name.include? @search_term) }
      else
        @constituencies.delete_if { |element| !(element.name.downcase.include? @search_term.downcase) }
        @members.delete_if { |element| !(element.member_name.downcase.include? @search_term.downcase) }
      end
    else
      @constituency = Constituency.find(id)
    end
  end

  def hide_members
    toggle_hide_members false
  end

  def unhide_members
    toggle_hide_members true
  end

  private
    def toggle_hide_members visible
      if is_admin? && request.post?
        Constituency.all.each do |constituency|
          if constituency.member_visible != visible
            constituency.member_visible = visible
            constituency.save
          end
        end
        redirect_to :back
      end
    end

    def ensure_current_constituency_url
      begin
        unless params[:id].include? '+'
          constituency = Constituency.find(params[:id])
          redirect_to constituency, :status => :moved_permanently if constituency.has_better_id?
        end
      rescue
        render_not_found
      end
    end
end
