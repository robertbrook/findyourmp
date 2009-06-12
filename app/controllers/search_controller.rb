class SearchController < ApplicationController

  def index
    params[:search_term] = params[:q] unless params[:q].blank?
    search_term = params[:search_term]

    params[:format] = params[:f] unless params[:f].blank?
    search_format = params[:format]

    do_search search_term, search_format
  end

  def redir
    params[:search_term] = params[:q] unless params[:q].blank?
    search_term = params[:search_term]
    @search_term = search_term.gsub('+',' ')
    redirect_to :action => 'index', :q => @search_term
  end

  def show
    render_show
  end

  private

    def render_show
      flash.keep(:postcode)
      params[:search_term] = params[:q] unless params[:q].blank?
      @search_term = params[:search_term]
      @last_search_term = @search_term
      @constituencies, @members = Constituency.find_all_constituency_and_member_matches @search_term

      respond_to do |format|
        format.html { render :template => '/constituencies/show' }
        format.xml  { redirect_to_api_search 'xml'  }
        format.json { redirect_to_api_search 'json' }
        format.js   { redirect_to_api_search 'js'   }
        format.text { redirect_to_api_search 'text' }
        format.csv  { redirect_to_api_search 'csv'  }
        format.yaml { redirect_to_api_search 'yaml' }
      end
    end

    def redirect_to_api_search format
      redirect_to :action=>'search', :controller=>'api', :q => @search_term, :f => format
    end

    def do_search search_term, search_format
      postcode_districts = PostcodeDistrict.find_all_by_district(search_term)

      unless postcode_districts.empty?
        redirect_to :controller => 'postcodes', :action => 'show', :postcode => search_term, :format => search_format
      else
        postcode = Postcode.find_postcode_by_code(search_term)

        if postcode
          redirect_to :controller => 'postcodes', :action=>'show', :postcode => postcode.code, :format => search_format
        else
          stripped_term = search_term ? search_term.strip : ''
          if stripped_term.size > 2
            constituencies = Constituency.find_all_name_or_member_name_matches(stripped_term)
            if constituencies.empty?
              flash[:not_found] = "not_found"
              flash[:last_search_term] = search_term
              if search_format
                show_error(search_format)
              else
                redirect_to root_url
              end
            elsif constituencies.size == 1
              redirect_to :controller => 'constituencies', :action => 'show', :id => constituencies.first.friendly_id, :format => search_format
            else
              if params[:commit].blank?
                render_show
              else
                redirect_to :controller => 'search', :action=>'index', :q => search_term, :format => search_format
              end
            end
          else
            flash[:not_found] = "not_found"
            flash[:last_search_term] = search_term
            if search_format
              show_error(search_format)
            else
              redirect_to root_url
            end
          end
        end
      end
    end

    def show_error format
      @error_message = flash[:not_found]

      respond_to do |format|
        format.html
        format.xml  { render :template => '/postcodes/error' }
        format.json { render :json => message_to_json("error", @error_message) }
        format.js   { render :json => message_to_json("error", @error_message) }
        format.text { render :text => message_to_text("error", @error_message) }
        format.csv  { render :text => message_to_csv("error", @error_message, "message", "content") }
        format.yaml { render :text => message_to_yaml("error", @error_message) }
      end
    end

end