class PostcodesController < ApplicationController

  def index
    search_term = params[:q]
    @postcode_count = Postcode.count
    @constituency_count = Constituency.count
    @last_search_term = flash[:last_search_term]

    unless search_term.blank?
      search_term.strip!
      search_term.upcase!
      postcode = Postcode.find_by_code(search_term.tr(' ',''))

      if postcode
        redirect_to :action=>'show', :postcode => postcode.code
      else
        constituencies = Constituency.find(:all, :conditions => %Q|name like "%#{search_term.squeeze(' ')}%"|)

        if constituencies.empty?
          flash[:not_found] = "No matches found for #{search_term}." if search_term
          flash[:last_search_term] = search_term if search_term
          redirect_to :action=>'index'
        elsif constituencies.size == 1
          redirect_to :controller=>'constituencies', :action=>'show', :id => constituencies.first.id
        else
          redirect_to :controller=>'constituencies', :action=>'show', :id => constituencies.collect(&:id).join('+'), :q => search_term
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
        flash[:not_found] = "No matches found for #{code}." if code
        flash[:last_search_term] = code
        params[:postcode] = nil
        redirect_to :action=>'index'
      end
    else
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
end
