require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/show.haml" do

  before do
    @constituency = mock_model(Constituency, :member_name => 'member_name',
        :member_party => 'member_party',
        :member_biography_url => 'http://here.it.is',
        :member_website => 'http://the.re',
        :no_sitting_member? => false,
        :member_email => "member@email",
        :member_requested_contact_url=>''
        )
    @constituency.stub!(:name).and_return("MyString")

    @other_constituency = mock_model(Constituency, :member_name => 'member_name',
        :member_party => 'member_party',
        :member_biography_url => '',
        :member_website => '',
        :no_sitting_member? => false,
        :member_email => "member@email",
        :member_requested_contact_url => nil
        )
      @other_constituency.stub!(:name).and_return("MyString")
  end

  it "should render attributes in <p>" do
    assigns[:constituency] = @constituency

    render "/constituencies/show.haml"
    response.should have_text(/MyString/)
  end

  it "should not render member website when the data is not supplied" do
    assigns[:constituency] = @other_constituency

    render "/constituencies/show.haml"
    response.should_not have_text(/Website:/)
  end

  it "should not render member biography when the data is not supplied" do
    assigns[:constituency] = @other_constituency

    render "/constituencies/show.haml"
    response.should_not have_text(/Biography:/)
  end
end

