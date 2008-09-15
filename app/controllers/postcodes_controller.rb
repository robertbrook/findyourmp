class PostcodesController < ApplicationController

  def index
  end

  def constituency
    code = params[:postcode].upcase
    postcode = Postcode.find_by_code(code)

    if postcode
      render :text => "constituency_id: #{postcode.constituency_id}"
    else
      render :text => "no constituency_id found for: #{code}"
    end
  end
end
