class BlacklistedPostcodesController < ApplicationController

  before_filter :require_admin_user

  def index
    @blacklist = BlacklistedPostcode.all
  end

  def restore
    code = params[:code].squeeze(' ').gsub(' ', '')
    blacklisted_code = BlacklistedPostcode.find_by_code code
    unless blacklisted_code.nil?
      blacklisted_code.restore
    end

    redirect_to :blacklisted_postcodes
  end

  def new
    if request.post?
      if params[:commit] == 'Confirm'
        code = flash[:code]
        postcode = Postcode.find_by_code code
        flash[:code] = nil
        postcode.blacklist unless postcode.nil?

        redirect_to :blacklisted_postcodes
      else
        if params[:blacklist]
          code = params[:blacklist][:code].squeeze(' ').gsub(' ', '')
          unless code.nil?
            flash[:code] = code
            @postcode = Postcode.find_by_code code
          end
        end
      end
    end
  end

end