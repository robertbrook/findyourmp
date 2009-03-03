class ConstituencyListsController < ApplicationController

  def edit
    @constituency_list = ConstituencyList.new
  end

  def update
    items = params['constituency_list']['items']
    @constituency_list = ConstituencyList.new
    @constituency_list.items = items
    @constituency_list.constituencies
  end
end
