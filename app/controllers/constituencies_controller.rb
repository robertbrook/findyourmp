class ConstituenciesController < ResourceController::Base

  caches_page :show

  before_filter :respond_unauthorized_if_not_admin, :except => ['show']

  before_filter :ensure_current_constituency_url, :only => :show

  def update
    load_object
    is_remote = (params[:commit]=="Update #{object.name}")

    before :update
    if object.update_attributes object_params
      after :update
      set_flash :update
      if is_remote
        @message = flash[:notice]
        flash[:notice] = nil
      else
        response_for(:update)
      end
    else
      after :update_fails
      set_flash :update_fails
      if is_remote
        @message = flash[:notice]
        flash[:notice] = nil
      else
        response_for(:update_fails)
      end
    end
  end

  def show
    id = params[:id]
    flash.keep(:postcode)

    if id.include? '+'
      @search_term = params[:search_term]
      @last_search_term = @search_term

      @constituencies = Constituency.find_all_by_id(id.split('+')).sort_by(&:name)
      @members = Constituency.find_all_by_id(id.split('+'), :conditions => "member_name is not null").sort_by(&:member_name)

      if @search_term[/[A-Z][a-z].*/]
        @constituencies.delete_if { |element| !(element.name.include? @search_term) }
        @members.delete_if { |element| !(element.member_name.include? @search_term) }
      else
        @constituencies.delete_if { |element| !(element.name.downcase.include? @search_term.downcase) }
        @members.delete_if { |element| !(element.member_name.downcase.include? @search_term.downcase) }
      end
      respond_to do |format|
        format.html
        format.xml
        format.json { render :json => results_to_json(@constituencies, @members) }
        format.js   { render :json => results_to_json(@constituencies, @members) }
        format.text { render :text => results_to_text(@constituencies, @members) }
        format.csv  { render :text => results_to_csv(@constituencies, @members) }
        format.yaml { render :text => results_to_yaml(@constituencies, @members) }
      end
    else
      @constituency = Constituency.find(id)

      @show_postcode_autodiscovery_links = true
      @url_for_this = url_for(:only_path=>false)
      respond_to do |format|
        format.html { @constituency }
        format.xml  { @constituency }
        format.json { render :json => @constituency.to_json }
        format.js   { render :json => @constituency.to_json }
        format.text { render :text => @constituency.to_text }
        format.csv  { render :text => @constituency.to_csv }
        format.yaml { render :text => @constituency.to_output_yaml }
      end
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
