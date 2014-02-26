#encoding: utf-8

require "./lib/members_names_data"

class ConstituencyListsController < ApplicationController

  before_filter :require_admin_user
  
  def edit
    @constituency_list = ConstituencyList.new
  end

  def update
    items = params['constituency_list']['items']
    @constituency_list = ConstituencyList.new
    @constituency_list.items = items
    
    @changed_constituencies = @constituency_list.changed_constituencies
    @unchanged_constituencies = @constituency_list.unchanged_constituencies
    
    @invalid_constituencies = @constituency_list.invalid_constituencies
    @unrecognized_constituencies = @constituency_list.unrecognized_constituencies
    @ommitted_constituencies = @constituency_list.ommitted_constituencies
  end
  
  def load_latest
    raw_data = MembersNamesData.new
    tsv = raw_data.to_tsv
    @constituency_list = ConstituencyList.new(tsv)
    render :edit
  end
end
