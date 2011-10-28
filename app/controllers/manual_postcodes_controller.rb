class ManualPostcodesController < ApplicationController

  before_filter :require_admin_user

  def index
    @manual_list = ManualPostcode.all
  end

  def new
    if request.post?
      if params[:commit] == 'Create manual postcode'
        code = flash[:code]
        flash[:code] = nil
        constituency_id = params[:manual_postcodes][:constituency]
        constituency = Constituency.find_by_id constituency_id
        postcode = ManualPostcode.add_manual_postcode code, constituency_id, constituency.ons_id

        redirect_to :manual_postcodes
      else
        if params[:manual_postcodes]
          code = params[:manual_postcodes][:code]
          unless code.nil?
            flash[:code] = code
            postcode = Postcode.find_by_code code
            unless postcode
              @constituencies = Constituency.all_constituencies
            end
          end
        end
      end
    end
  end

  def remove
    code = params[:code]
    manual_code = ManualPostcode.find_by_code code
    unless manual_code.nil?
      manual_code.remove
    end

    redirect_to :manual_postcodes
  end
end