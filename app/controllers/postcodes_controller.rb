class PostcodesController < ApplicationController

  def index
    code = params[:postcode]

    if code
      code.strip!
      code.upcase!
      postcode = Postcode.find_by_code(code.tr(' ',''))

      if postcode
        redirect_to :action=>'show',:postcode=>postcode.code
      else
        render :text => "no constituency_id found for: #{code.squeeze(' ')}"
      end
    end
  end

  def show
    code = params[:postcode]
    postcode = Postcode.find_by_code(code)
    if postcode
      
      respond_to do |wants|
          wants.html {render :text => "constituency_id: #{postcode.constituency_id}"}
          wants.xml { render :text => "some xml" }
        end
      
      

      
    else
      redirect_to :action=>'index'
    end
  end
end
