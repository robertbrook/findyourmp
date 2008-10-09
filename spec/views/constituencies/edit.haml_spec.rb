require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituency/edit.haml" do

  before do
    member = mock_model(Member, :name => 'name')
    @constituency = mock_model(Constituency, :member => member)
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