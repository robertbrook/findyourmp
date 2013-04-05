require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/edit.haml" do

  before do
    @constituency = mock_model(Constituency, :member_name => 'member_name',
        :ons_id=>300,
        :member_party=>'',
        :member_email=>'',
        :member_requested_contact_url=>'',
        :member_biography_url=>'',
        :member_website=>'',
        :member_visible=>false
      )
    @constituency.stub!(:name).and_return("MyString")
  end

  it "should render edit form" do
    assign(:constituency, @constituency)
    render
    view.should render_template(:edit)
    
    response.should have_selector("form", :method => "post", :action => "#{constituency_path(@constituency)}")
    response.body.should have_field("constituency_name", :with => @constituency.name)
  end
end