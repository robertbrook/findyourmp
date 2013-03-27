class ConstituenciesController < ApplicationController  
  caches_page :show, :if => '!is_admin?'
  cache_sweeper :constituency_sweeper, :only => [:update, :destroy, :hide_members, :unhide_members]

  before_filter :respond_unauthorized_if_not_admin, :except => [:index, :show, :redir]

  before_filter :redirect_to_root_if_not_admin, :only => :index

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

  def redir
    up_my_street_code = params[:up_my_street_code]
    constituency = UpMyStreetCode.find_constituency_url_slug(up_my_street_code)
    if constituency
      redirect_to :action => 'show', :id => constituency
    else
      redirect_to :root
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
      format.json { render :json => @constituency.to_json(request.host, request.port) }
      format.js   { render :json => @constituency.to_json(request.host, request.port) }
      format.text { render :text => @constituency.to_text(request.host, request.port) }
      format.csv  { render :text => @constituency.to_csv(request.host, request.port) }
      format.yaml { render :text => @constituency.to_output_yaml(request.host, request.port) }
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
        redirect_to constituency, :status => :moved_permanently if params[:id] != constituency.slug
      rescue
        render_not_found
      end
    end

end
