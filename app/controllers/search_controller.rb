class SearchController < ApplicationController

  caches_page :show
  cache_sweeper :constituency_sweeper, :only => [:create, :update, :destroy]

  def index
    search_term = params[:search_term]
    search_format = params[:format]
    
    do_search search_term, search_format
  end
  
  def show
    flash.keep(:postcode)
    @search_term = params[:search_term]
    @last_search_term = @search_term

    @constituencies = Constituency.find_all_name_or_member_name_matches(@search_term)
    @members = @constituencies.clone
     
    if @search_term[/[A-Z][a-z].*/]
      @constituencies.delete_if { |element| !(element.name.include? @search_term) }
      @members.delete_if { |element| !(element.member_name.include? @search_term) }
    else
      @constituencies.delete_if { |element| !(element.name.downcase.include? @search_term.downcase) }
      @members.delete_if { |element| !(element.member_name.downcase.include? @search_term.downcase) }
    end
    
    @constituencies = @constituencies.sort_by { |record| record.name }
    @members = @members.sort_by { |record| record.member_name }
    
    respond_to do |format|
      format.html { render :template => '/constituencies/show' }
      format.xml  { render :template => '/constituencies/show' }
      format.json { render :json => results_to_json(@constituencies, @members) }
      format.js   { render :json => results_to_json(@constituencies, @members) }
      format.text { render :text => results_to_text(@constituencies, @members) }
      format.csv  { render :text => results_to_csv(@constituencies, @members) }
      format.yaml { render :text => results_to_yaml(@constituencies, @members) }
    end
  end
  
  private
  
    def do_search search_term, search_format
      postcode_districts = PostcodeDistrict.find_all_by_district(search_term)

      unless postcode_districts.empty?
        redirect_to :controller => 'postcodes', :action => 'show', :postcode => search_term, :format => search_format
      else
        postcode = Postcode.find_postcode_by_code(search_term)

        if postcode
          redirect_to :controller => 'postcodes', :action=>'show', :postcode => postcode.code, :format => search_format
        else
          stripped_term = search_term.strip
          if stripped_term.size > 2
            constituencies = Constituency.find_all_name_or_member_name_matches(stripped_term)
            if constituencies.empty?
              flash[:not_found] = "<p>Sorry: we couldn't find a constituency when we searched for <code>#{search_term}</code>. If you were searching for a postcode, please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>"
              flash[:last_search_term] = search_term
              if search_format
                show_error(search_format)
              else
                redirect_to root_url
              end
            elsif constituencies.size == 1
              redirect_to :controller=>'constituencies', :action=>'show', :id => constituencies.first.friendly_id, :format => search_format
            else
              redirect_to :controller=> 'search', :action=>'show',:search_term => search_term, :format => search_format
            end
          else
            flash[:not_found] = "<p>Sorry: we need more than two letters to search</p>"
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