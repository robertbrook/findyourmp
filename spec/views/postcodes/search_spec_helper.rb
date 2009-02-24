require File.dirname(__FILE__) + '/../../spec_helper'

describe "renders search form", :shared => true do
  def do_render
    @layout ? render(@template, :layout=>@layout) : render(@template)
  end
  it "should render search form" do
    do_render
    response.should have_tag('form')
  end
  it "should show search term input field" do
    do_render
    response.should have_tag("input[id=search_term][name=search_term]")
  end
  it 'should show search term in input field if term is assigned to view' do
    if @searched_for
      do_render
      response.should have_tag("input[id=search_term][name=search_term][value=#{@searched_for}]")
    end
  end
  it 'should show submit search button' do
    do_render
    response.should have_tag("input[value=Search][type=submit]")
  end
end
