class ConstituenciesController < ResourceController::Base

  caches_page :show
  cache_sweeper :constituency_sweeper, :only => [:create, :update, :destroy]

  before_filter :respond_unauthorized_if_not_admin, :except => [:show]

  before_filter :ensure_current_constituency_url, :only => :show

  def update
    load_object
    before :update

    if object.update_attributes object_params
      after :update
      set_flash :update
      if is_remote?
        @message = flash[:notice]
        flash[:notice] = nil
        render 'update', :layout => false
      else
        response_for(:update)
      end
    else
      after :update_fails
      set_flash :update_fails
      if is_remote?
        @message = flash[:notice]
        flash[:notice] = nil
        render 'update', :layout => false
      else
        response_for(:update_fails)
      end
    end
  end

  def show
    id = params[:id]
    flash.keep(:postcode)

    @constituency = Constituency.find(id)

    @show_postcode_autodiscovery_links = true
    @url_for_this = url_for(:only_path=>false)
    respond_to do |format|
      format.html { @constituency }
      format.xml  { render :xml => @constituency }
      format.json { render :json => @constituency.to_json }
      format.js   { render :json => @constituency.to_json }
      format.text { render :text => @constituency.to_text }
      format.csv  { render :text => @constituency.to_csv }
      format.yaml { render :text => @constituency.to_output_yaml }
    end
  end

  def hide_members
    toggle_hide_members false
  end

  def unhide_members
    toggle_hide_members true
  end

  private

    def is_remote?
      (params[:commit]=="Update #{object.name}")
    end

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
        constituency = Constituency.find(params[:id])
        redirect_to constituency, :status => :moved_permanently if constituency.has_better_id?
      rescue
        render_not_found
      end
    end

end
