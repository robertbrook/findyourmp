class PostcodesController < ApplicationController
  
  caches_page :show

  def index
    @last_search_term = flash[:last_search_term]
  end

  def show
    code = params[:postcode]
    postcode_districts = PostcodeDistrict.find_all_by_district(code)

    unless postcode_districts.empty?
      render_postcode_districts code, postcode_districts
    else
      postcode = Postcode.find_postcode_by_code(code)

      if postcode
        render_postcode code, postcode
      else
        render_no_search_matches code
      end
    end
  end

  private

    def render_postcode_districts code, postcode_districts
      flash[:postcode] = postcode_districts.first.district
      if postcode_districts.size == 1
        redirect_to :action=>'show', :controller=>'constituencies', :id=>postcode_districts.first.friendly_id, :format=>params[:format]
      else
        @search_term = code
        @show_postcode_autodiscovery_links = true
        @url_for_this = url_for(:only_path=>false)
        respond_to do |format|
          @constituencies = postcode_districts.collect { |postcode| postcode.constituency }
          format.html { @postcode_districts = postcode_districts }
          format.xml  { render :xml, :template => '/constituencies/show', :layout => false }
          format.json { render :json => results_to_json(@constituencies, []) }
          format.js   { render :json => results_to_json(@constituencies, []) }
          format.text { render :text => results_to_text(@constituencies, []) }
          format.csv  { render :text => results_to_csv(@constituencies, []) }
          format.yaml { render :text => results_to_yaml(@constituencies, []) }
        end
      end
    end

    def render_postcode code, postcode
      if postcode.code != code
        redirect_to :action=>'show', :postcode=>postcode.code, :format => params[:format]
      else
        @show_postcode_autodiscovery_links = true
        @url_for_this = url_for(:only_path=>false)
        respond_to do |format|
          format.html do ||
            @postcode = postcode
            @constituency = postcode.constituency
            flash[:postcode] = @postcode.code_with_space
            if @constituency
              redirect_to constituency_path(:id=>@constituency.friendly_id)
            end
          end
          format.xml  { render :xml => @postcode = postcode; @constituency = postcode.constituency }
          format.json { render :json => postcode.to_json }
          format.js   { render :json => postcode.to_json }
          format.text { render :text => postcode.to_text }
          format.csv  { render :text => postcode.to_csv }
          format.yaml { render :text => postcode.to_output_yaml }
        end
      end
    end

    def render_no_search_matches code
      flash[:not_found] = "<p>Sorry: we couldn't find a postcode when we searched for <code>#{code}</code>. Please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>" if code
      flash[:last_search_term] = code
      params[:postcode] = nil
      search_format = params[:format]
      if search_format
        show_error(search_format)
      else
        redirect_to :action=>'index'
      end
    end
    
    def show_error format
      @error_message = flash[:not_found]

      respond_to do |format|
        format.html
        format.xml  { render :template => '/postcodes/error', :layout => false }
        format.json { render :json => message_to_json("error", @error_message) }
        format.js   { render :json => message_to_json("error", @error_message) }
        format.text { render :text => message_to_text("error", @error_message) }
        format.csv  { render :text => message_to_csv("error", @error_message, "message", "content") }
        format.yaml { render :text => message_to_yaml("error", @error_message) }
      end
    end
    
end
