require File.dirname(__FILE__) + '/../../spec_helper'

describe "/members/edit.haml" do

  before do
    @member_id = 5
    @constituency_id = 15
    member = mock_model(Member, :name => 'name', :id => @member_id, :constituency_id => @constituency_id)
    @constituency = mock_model(Constituency, :member => member, :id => @constituency_id)
    @constituency.stub!(:name).and_return("MyString")
    assigns[:constituency] = @constituency
  end

  it "should render edit form" do
    render "/members/edit.haml"
    response.should have_tag("form[action=#{constituency_member_path(@constituency)}][method=post]") do
      with_tag('input#member_name[name=?]', "member[name]")
    end
  end
end