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
    if code
      postcode = Postcode.find_by_code(code)
      render :text => "constituency_id: #{postcode.constituency_id}"
    end
  end
end
