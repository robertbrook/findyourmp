class PostcodesController < ApplicationController

  def index
    search_term = params[:search_term]
    search_format = params[:format]

    @postcode_count = Postcode.count
    @constituency_count = Constituency.count
    @last_search_term = flash[:last_search_term]
    
    unless search_term.blank?
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
              redirect_to :action=>'error', :format=>search_format
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
            redirect_to :action=>'error', :format=>search_format
          else
            redirect_to :action=>'index'
          end
        end
      end
    end
  end

  def show
    code = params[:postcode]
    postcode = Postcode.find_postcode_by_code(code)

    unless postcode
      postcode = Postcode.find_postcode_by_code(code.tr(' ',''))
      if postcode
        redirect_to :action=>'show', :postcode=>postcode.code
      else
        flash[:not_found] = "<p>Sorry: we couldn't find a postcode when we searched for <code>#{code}</code>. Please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>" if code
        flash[:last_search_term] = code
        params[:postcode] = nil
        search_format = params[:format]
        if search_format
          redirect_to :action=>'error', :format=>search_format
        else
          redirect_to :action=>'index'
        end
      end
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
  end
  
  def error
    @error_message = flash[:not_found]
    
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => message_to_json("error", @error_message) }
      format.js   { render :json => message_to_json("error", @error_message) }
      format.text { render :text => message_to_text("error", @error_message) }
      format.csv  { render :text => message_to_csv("error", @error_message, "message", "content") }
      format.yaml { render :text => message_to_yaml("error", @error_message) }
    end
  end
  
  private
  
    def message_to_json root, message
      %Q|{"#{root}": "#{message}"}|
    end

    def message_to_text root, message
      %Q|#{root}: #{message}\n|
    end

    def message_to_csv root, message, root_header, message_header
      headers = %Q|"#{root_header}","#{message_header}"|
      values = %Q|"#{root}","#{message}"|
      "#{headers}\n#{values}\n"
    end

    def message_to_yaml root, message
      "---\n#{message_to_text(root, message)}"
    end
  
end
