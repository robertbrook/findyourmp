require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/show.haml" do

  before do
    member = mock_model(Member, :name => 'name')
    @constituency = mock_model(Constituency, :member => member)
    @constituency.stub!(:name).and_return("MyString")

    assigns[:constituency] = @constituency
  end

  it "should render attributes in <p>" do
    render "/constituencies/show.haml"
    response.should have_text(/MyString/)
  end
end

