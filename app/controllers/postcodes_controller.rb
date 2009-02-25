class PostcodesController < ApplicationController

  def index
    search_term = params[:search_term]
    search_format = params[:format]

    @last_search_term = flash[:last_search_term]
    
    unless search_term.blank?
      do_search search_term, search_format
    end
  end

  def show
    code = params[:postcode]
    postcodes = PostcodePrefix.find_all_by_prefix(code)
    
    if postcodes
      if postcodes.size == 1
        redirect_to :action=>'show', :controller=>'constituencies', :id=>postcodes.first.id, :format=>params[:format]
      else
        @search_term = code
        @show_postcode_autodiscovery_links = true
        @url_for_this = url_for(:only_path=>false)
        respond_to do |format|
          @constituencies = postcodes.collect { |postcode| postcode.constituency }
          format.html { @postcodes = postcodes }
          format.xml  { render :template => '/constituencies/show' }
          format.json { render :json => results_to_json(@constituencies, []) }
          format.js   { render :json => results_to_json(@constituencies, []) }
          format.text { render :text => results_to_text(@constituencies, []) }
          format.csv  { render :text => results_to_csv(@constituencies, []) }
          format.yaml { render :text => results_to_yaml(@constituencies, []) }
        end
      end
    else
      postcode = Postcode.find_postcode_by_code(code)
    
      if postcode
        if postcode.code != code
          redirect_to :action=>'show', :postcode=>postcode.code, :format => params[:format]
        else
          @show_postcode_autodiscovery_links = true
          @url_for_this = url_for(:only_path=>false)
          respond_to do |format|
            format.html { @postcode = postcode; @constituency = postcode.constituency; flash[:postcode] = @postcode.code_with_space }
            format.xml  { @postcode = postcode; @constituency = postcode.constituency }
            format.json { render :json => postcode.to_json }
            format.js   { render :json => postcode.to_json }
            format.text { render :text => postcode.to_text }
            format.csv  { render :text => postcode.to_csv }
            format.yaml { render :text => postcode.to_output_yaml }
          end
        end
      else
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
    end
  end

  private
  
    def do_search search_term, search_format
      postcodes = PostcodePrefix.find_all_by_prefix(search_term)
      
      if postcodes
        redirect_to :action => 'show', :postcode => search_term, :format => search_format
      else
        postcode = Postcode.find_postcode_by_code(search_term)

        if postcode
          redirect_to :action=>'show', :postcode => postcode.code, :format => search_format
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
                redirect_to :action=>'index'
              end
            elsif constituencies.size == 1
              redirect_to :controller=>'constituencies', :action=>'show', :id => constituencies.first.friendly_id, :format => search_format
            else
              redirect_to :controller=> 'constituencies', :action=>'show', :id => constituencies.collect(&:id).join('+'), :search_term => search_term, :format => search_format
            end
          else
            flash[:not_found] = "<p>Sorry: we need more than two letters to search</p>"
            flash[:last_search_term] = search_term
            if search_format
              show_error(search_format)
            else
              redirect_to :action=>'index'
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
