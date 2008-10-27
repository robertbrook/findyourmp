class PostcodesController < ApplicationController

  def index
    code = params[:postcode]
    @postcode_count = Postcode.count
    @constituency_count = Constituency.count

    unless code.blank?
      code.strip!
      code.upcase!
      postcode = Postcode.find_by_code(code.tr(' ',''))

      if postcode
        redirect_to :action=>'show', :postcode => postcode.code
      else
        constituency = Constituency.find(:all, :conditions => %Q|name like "#{code.squeeze(' ')}"|)

        if constituency.empty?
          flash[:not_found] = "Postcode #{code} not found." if code
          redirect_to :action=>'index'
        elsif constituency.size == 1
          redirect_to :controller=>'constituencies', :action=>'show', :id => constituency.first.id
        else
          raise 'case not covered yet'
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
        flash[:not_found] = "Postcode #{code} not found." if code
        params[:postcode] = nil
        redirect_to :action=>'index'
      end
    else
      respond_to do |format|
        format.html { @postcode = postcode }
        format.xml  { @postcode = postcode }
        format.json { render :json => postcode.to_json }
        format.js   { render :json => postcode.to_json }
        format.text { render :text => postcode.to_text }
        format.csv  { render :text => postcode.to_csv }
        format.yaml { render :text => postcode.to_output_yaml }
      end
    end
  end
end
