require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/show.haml" do

  before do
    @constituency = mock_model(Constituency, :member_name => 'member_name', :member_party => 'member_party', :member_biography_url => 'http://here.it.is')
    @constituency.stub!(:name).and_return("MyString")

    assigns[:constituency] = @constituency
  end

  it "should render attributes in <p>" do
    render "/constituencies/show.haml"
    response.should have_text(/MyString/)
  end
end

