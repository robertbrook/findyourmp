require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/new.haml" do

  before do
    @constituency = Constituency.new
    @constituency.stub!(:new_record?).and_return(true)
    @constituency.stub!(:name).and_return("MyString")
  end

  it "should render new form" do
    render
    view.should render_template(:new)
    
    response.should have_selector("form", :method => "post", :action => constituencies_path)
    response.body.should have_field("constituency_name")
  end
end
