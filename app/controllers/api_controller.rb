class ApiController < ApplicationController
  
  def index
    # help text goes here
  end
  
  def search
    search_term = params[:search_term]
    search_format = params[:format]
    
    postcode = Postcode.find_postcode_by_code(search_term)
    
    if postcode
      show_postcode(postcode, search_format)
    else
      stripped_term = search_term.strip
      if stripped_term.size > 2
        constituencies = Constituency.find_all_name_or_member_name_matches(stripped_term)
        if constituencies.empty?
          flash[:not_found] = "<p>Sorry: we couldn't find a constituency when we searched for <code>#{search_term}</code>. If you were searching for a postcode, please go back and check the postcode you entered, and ensure you have entered a <strong>complete</strong> postcode.</p> <p>If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP.</p>"
          flash[:last_search_term] = search_term
          show_error(search_format)
        elsif constituencies.size == 1
          show_constituency(constituencies.first, search_format)
        else
          show_constituencies(constituencies, search_term, search_format)
        end
      else
        flash[:not_found] = "<p>Sorry: we need more than two letters to search</p>"
        flash[:last_search_term] = search_term
        show_error(search_format)
      end
    end
  end
  
  # def postcode
  # end
  # 
  # def constituency
  # end
  
  private
  
    def show_postcode postcode, format
      @postcode = postcode
      @constituency = postcode.constituency
      
      respond_to do |format|
        format.html { render :template => '/postcodes/show', :postcode => postcode } 
        format.xml  { render :template => '/postcodes/show', :postcode => postcode }
        format.json { render :json => postcode.to_json }
        format.js   { render :json => postcode.to_json }
        format.text { render :text => postcode.to_text }
        format.csv  { render :text => postcode.to_csv }
        format.yaml { render :text => postcode.to_output_yaml }
      end
    end
    
    def show_constituency constituency, format
      @constituency = constituency
      
     respond_to do |format|
        format.html { render :template => '/constituencies/show' } 
        format.xml  { render :template => '/constituencies/show' }
        format.json { render :json => constituency.to_json }
        format.js   { render :json => constituency.to_json }
        format.text { render :text => constituency.to_text }
        format.csv  { render :text => constituency.to_csv }
        format.yaml { render :text => constituency.to_output_yaml }
      end
    end
    
    def show_constituencies constituencies, search_term, format
      @constituencies = constituencies
      @members = constituencies.clone

      if search_term[/[A-Z][a-z].*/]
        @constituencies.delete_if { |element| !(element.name.include? search_term) }
        @members.delete_if { |element| !(element.member_name.include? search_term) }
      else
        @constituencies.delete_if { |element| !(element.name.downcase.include? search_term.downcase) }
        @members.delete_if { |element| !(element.member_name.downcase.include? search_term.downcase) }
      end
      
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
    
    def show_error format
      @error_message = flash[:not_found]

      respond_to do |format|
        format.html { render :template => '/postcodes/index'}
        format.xml  { render :template => '/postcodes/error' }
        format.json { render :json => message_to_json("error", @error_message) }
        format.js   { render :json => message_to_json("error", @error_message) }
        format.text { render :text => message_to_text("error", @error_message) }
        format.csv  { render :text => message_to_csv("error", @error_message, "message", "content") }
        format.yaml { render :text => message_to_yaml("error", @error_message) }
      end
    end

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
    
    def results_to_json constituencies, members
      constituencies_json = ""
      constituencies.each do |constituency|
        constituencies_json += ", " unless constituencies_json == ""
        constituencies_json += constituency.to_json[1..-2]
      end

      members_json = ""
      members.each do |member|
        members_json += ", " unless members_json == ""
        members_json += member.to_json[1..-2]
      end

      constituencies_results = %Q|"constituencies": {#{constituencies_json}}|
      members_results = %Q|"members": {#{members_json}}|

      %Q|{"results": { #{constituencies_results}, #{members_results} }} |
    end

    def results_to_text constituencies, members
      results = ""
      constituencies.each do |constituency|
        results += "\n\n"
        results += "  - " + constituency.to_text.gsub("\n", "\n\    ")
      end
      members.each do |member|
        results += "\n\n"
        results += "  - " + member.to_text.gsub("\n", "\n    ")
      end
      "constituencies:" + results
    end

    def results_to_yaml constituencies, members
      "---\n#{results_to_text(constituencies, members)}"
    end

    def results_to_csv constituencies, members
      headers = 'constituency_name,constituency_id,member_name,member_party,member_biography_url,member_website'
      values = ""

      constituencies.each do |constituency|
        values += constituency.to_csv_value + "\n"
      end

      members.each do |constituency|
        values += constituency.to_csv_value + "\n"
      end

      "#{headers}\n#{values}\n"
    end
end