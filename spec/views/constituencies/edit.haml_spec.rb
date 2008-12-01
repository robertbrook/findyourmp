require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituency/edit.haml" do

  before do
    @constituency = mock_model(Constituency, :member_name => 'member_name',
        :member_party=>'',
        :member_email=>'',
        :member_biography_url=>'',
        :member_website=>'',
        :member_visible=>false
      )
    @constituency.stub!(:name).and_return("MyString")
    assigns[:constituency] = @constituency
  end

  it "should render edit form" do
    render "/constituencies/edit.haml"

    response.should have_tag("form[action=#{constituency_path(@constituency)}][method=post]") do
      with_tag('input#constituency_name[name=?]', "constituency[name]")
    end
  end
end