require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/show.haml" do

  before do
    @constituency = Constituency.new( :member_name => 'member_name',
        :member_party => 'member_party',
        :member_biography_url => 'http://here.it.is',
        :member_website => 'http://the.re',
        :member_email => "member@email",
        :member_requested_contact_url=>'',
        :name => "Islington North",
        :member_visible => true)
    @constituency.stub!(:friendly_id).and_return 'islington_north'

    @other_constituency = Constituency.new( :member_name => 'member_name',
        :member_party => 'member_party',
        :member_biography_url => '',
        :member_website => '',
        :member_email => "member@email",
        :member_requested_contact_url => nil,
        :name => "Islington South",
        :member_visible => true)
    @other_constituency.stub!(:friendly_id).and_return 'islington_south'
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

  it 'should not show member name if no sitting member' do
    @constituency.stub!(:member_visible).and_return false
    assigns[:constituencies] = [@constituency, @other_constituency]
    assigns[:members] = []

    render "/constituencies/show.haml"
    response.should have_text(/Islington North<\/a>\n  &mdash; no sitting Member/)
    response.should have_text(/Islington South<\/a>\n  &mdash; member_name/)
  end
end
