class ConstituencyListsController < ApplicationController

  def edit
    @constituency_list = ConstituencyList.new
  end

  def update
    items = params['constituency_list']['items']
    @constituency_list = ConstituencyList.new
    @constituency_list.items = items

    @changed_constituencies = @constituency_list.changed_constituencies
    @unchanged_constituencies = @constituency_list.unchanged_constituencies
  end
end
