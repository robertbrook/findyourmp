require File.dirname(__FILE__) + '/../../spec_helper'

shared_examples "renders search form" do
  def do_render
    render
    #@layout ? render_template(@template, :layout=>@layout) : render_template(@template)
  end
  
  it "should render search form" do
    render
    view.should render_template(:"layouts/_search_form")
    response.should have_selector("form")
  end
  
  it "should show search term input field" do
    do_render
    response.should have_field("q")
  end
  
  it 'should show search term in input field if term is assigned to view' do
    if @searched_for
      do_render
      response.should have_field("q", :value => @searched_for)
    end
  end
  
  it 'should show submit search button' do
    do_render
    response.should have_selector("input", :type => "submit", :value => "Find MP")
  end
end
