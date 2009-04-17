require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/show.haml" do

  before do
    @constituency = Constituency.new( :member_name => 'member_name',
        :member_party => 'member_party',
        :member_biography_url => 'http://here.it.is',
        :member_website => 'http://the.re',
        :member_email => "member@email",
        :member_requested_contact_url=>'',
        :name => "Islington North")

    @other_constituency = Constituency.new( :member_name => 'member_name',
        :member_party => 'member_party',
        :member_biography_url => '',
        :member_website => '',
        :member_email => "member@email",
        :member_requested_contact_url => nil,
        :name => "Islington South")
    @controller.stub!(:current_user).and_return nil
  end

  it "should not render member website when the data is not supplied" do
    assigns[:constituency] = @other_constituency

    render "/constituencies/show.haml"
    response.should_not have_text(/Website/)
  end

  it "should not render member biography when the data is not supplied" do
    assigns[:constituency] = @other_constituency

    render "/constituencies/show.haml"
    response.should_not have_text(/Biography/)
  end
end
