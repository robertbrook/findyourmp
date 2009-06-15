class ApiController < ApplicationController

  def index
  end

  def search
    params[:search_term] = params[:q] unless params[:q].blank?
    search_term = params[:search_term]

    params[:format] = params[:f] unless params[:f].blank?
    search_format = params[:format]

    if search_term
      postcode_districts = PostcodeDistrict.find_all_by_district(search_term)

      unless postcode_districts.empty?
        show_postcode_districts(postcode_districts, search_format)
      else
        postcode = Postcode.find_postcode_by_code(search_term)

        if postcode
          show_postcode(postcode, search_term, search_format)
        else
          stripped_term = search_term.strip.squeeze(' ').gsub('"','')
          if stripped_term.size > 2
            constituencies = Constituency.find_all_name_or_member_name_matches(stripped_term)
            if constituencies.empty?
              flash[:not_found] = "not_found"
              flash[:last_search_term] = search_term
              show_error(search_format)
            elsif constituencies.size == 1
              show_constituencies([constituencies.first], stripped_term, search_format)
            else
              show_constituencies(constituencies, stripped_term, search_format)
            end
          else
            flash[:not_found] = "Sorry: we need more than two letters to search"
            flash[:last_search_term] = search_term
            show_error(search_format)
          end
        end
      end
    else
      flash[:not_found] = "Sorry: the API did not recognise this parameter"
      show_error(search_format)
    end
  end

  def postcodes
    code = params[:code]
    district = params[:district]
    params[:format] = params[:f] unless params[:f].blank?
    search_format = params[:format]

    if district
      postcode_districts = PostcodeDistrict.find_all_by_district(district)
      unless postcode_districts.empty?
        show_postcode_districts(postcode_districts, search_format)
      else
        flash[:not_found] = "Sorry: we couldn't find a postcode when we searched for #{district}. Please go back and check the postcode you entered, and ensure you have entered a complete postcode. If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP."
        show_error(search_format)
      end
    elsif code
      postcode = Postcode.find_postcode_by_code(code)

      if postcode
        show_postcode(postcode, code, search_format)
      else
        flash[:not_found] = "Sorry: we couldn't find a postcode when we searched for #{code}. Please go back and check the postcode you entered, and ensure you have entered a complete postcode. If you are an expatriate, in an overseas territory, a Crown dependency or in the Armed Forces without a postcode, this service cannot be used to find your MP."
        show_error(search_format)
      end
    else
      flash[:not_found] = "Sorry: the API did not recognise this parameter"
      show_error(search_format)
    end
  end

  def constituencies
    member_name = params[:member]
    constituency_name = params[:constituency]
    ons_id = params[:ons_id]
    params[:format] = params[:f] unless params[:f].blank?
    search_format = params[:format]

    if ons_id
      ons_id = ons_id.strip.gsub('"','')
      constituency = Constituency.find_by_ons_id(ons_id)
      if constituency
        show_constituency(constituency, search_format)
      else
        flash[:not_found] = "Sorry: we couldn't find a constituency with an ONS id of #{ons_id}"
        show_error(search_format)
      end
    elsif member_name
      member_name = member_name.strip.gsub('"','')
      constituency = Constituency.find_by_member_name(member_name)
      if constituency
        show_constituency(constituency, search_format)
      else
        flash[:not_found] = "Sorry: we couldn't find a constituency with a member name of #{member_name}"
        show_error(search_format)
      end
    elsif constituency_name
      constituency_name = constituency_name.strip.gsub('"','')
      constituency = Constituency.find_by_name(constituency_name)
      if constituency
        show_constituency(constituency, search_format)
      else
        flash[:not_found] = "Sorry: we couldn't find a constituency with a constituency name of #{constituency_name}"
        show_error(search_format)
      end
    else
      flash[:not_found] = "Sorry: the API did not recognise this parameter"
      show_error(search_format)
    end
  end


  private

    def show_postcode postcode, search_term, format
      show_constituencies([postcode.constituency], nil, format)

      # @postcode = postcode
      # @constituency = postcode.constituency
      # respond_to do |format|
        # format.html { render :template => '/postcodes/show', :postcode => postcode }
        # format.xml  { render :template => '/postcodes/show', :postcode => postcode, :layout => false }
        # format.json { render :json => postcode.to_json }
        # format.js   { render :json => postcode.to_json }
        # format.text { render :text => postcode.to_text }
        # format.csv  { render :text => postcode.to_csv }
        # format.yaml { render :text => postcode.to_output_yaml }
      # end
    end

    def show_postcode_districts postcode_districts, format
      @search_term = ""
      respond_to do |format|
        @postcode_districts = postcode_districts
        @constituencies = postcode_districts.collect { |postcode| postcode.constituency }
        format.html { render :template => '/postcodes/show' }
        format.xml  { render :template => '/constituencies/show', :layout => false }
        format.json { render :json => results_to_json(@constituencies, []) }
        format.js   { render :json => results_to_json(@constituencies, []) }
        format.text { render :text => results_to_text(@constituencies, []) }
        format.csv  { render :text => results_to_csv(@constituencies, []) }
        format.yaml { render :text => results_to_yaml(@constituencies, []) }
      end
    end

    def show_constituency constituency, format
      @constituency = constituency

      respond_to do |format|
        format.html { render :template => '/constituencies/show' }
        format.xml  { render :template => '/constituencies/show.xml.haml', :layout => false }
        format.json { render :json => constituency.to_json }
        format.js   { render :json => constituency.to_json }
        format.text { render :text => constituency.to_text }
        format.csv  { render :text => constituency.to_csv }
        format.yaml { render :text => constituency.to_output_yaml }
      end
    end

    def show_constituencies constituencies, search_term, format
      @constituencies = constituencies

      if search_term
        @members = constituencies.clone

        if search_term[/[A-Z][a-z].*/]
          @constituencies.delete_if { |c| !(c.name.include? search_term) }
          @members.delete_if { |c| c.member_name.blank? || !(c.member_name.include? search_term) }
        else
          @constituencies.delete_if { |c| !(c.name.downcase.include? search_term.downcase) }
          @members.delete_if { |c| c.member_name.blank? || !(c.member_name.downcase.include? search_term.downcase) }
        end
      else
        @members = []
      end

      respond_to do |format|
         format.html { render :template => '/constituencies/show' }
         format.xml  { render :template => '/constituencies/show', :layout => false }
         format.json { render :json => results_to_json(@constituencies, @members, params[:callback]) }
         format.js   { render :json => results_to_json(@constituencies, @members, params[:callback]) }
         format.text { render :text => results_to_text(@constituencies, @members) }
         format.csv  { render :text => results_to_csv(@constituencies, @members) }
         format.yaml { render :text => results_to_yaml(@constituencies, @members) }
       end

    end

    def show_error format
      @error_message = flash[:not_found]

      respond_to do |format|
        format.html { render :template => '/api/index'}
        format.xml  { render :template => '/postcodes/error', :layout => false }
        format.json { render :json => message_to_json("error", @error_message) }
        format.js   { render :json => message_to_json("error", @error_message) }
        format.text { render :text => message_to_text("error", @error_message) }
        format.csv  { render :text => message_to_csv("error", @error_message, "message", "content") }
        format.yaml { render :text => message_to_yaml("error", @error_message) }
      end
    end

end