require File.dirname(__FILE__) + '/../../spec_helper'

describe "/constituencies/show.haml" do

  before do
    @constituency = Constituency.new()
    @constituency.member_name = 'member_name'
    @constituency.member_party = 'member_party'
    @constituency.member_biography_url = 'http://here.it.is'
    @constituency.member_website = 'http://the.re'
    @constituency.member_email = "member@email"
    @constituency.member_requested_contact_url = ''
    @constituency.name = "Islington North"
    @constituency.member_visible = true
    @constituency.stub!(:friendly_id).and_return 'islington_north'

    @other_constituency = Constituency.new()
    @other_constituency.member_name = 'member_name'
    @other_constituency.member_party = 'member_party'
    @other_constituency.member_biography_url = ''
    @other_constituency.member_website = ''
    @other_constituency.member_email = "member@email"
    @other_constituency.member_requested_contact_url = nil
    @other_constituency.name = "Islington South"
    @other_constituency.member_visible = true
    @other_constituency.stub!(:friendly_id).and_return 'islington_south'
  end

  describe "when given a single constituency" do
    it "should render all the details" do
      render(:template => "constituencies/show.html")
      view.should render_template(:"_member")
      view.should render_template(:"_constituency")
      view.should render_template(:show)
      
      response.should have_selector("a", :href => "http://here.it.is", :content => "member_name")
      response.should have_selector("div", :class => "row_label", :content => "Party")
      response.should have_selector("div", :class => "row_value", :content => "member_party")
      response.should have_selector("div", :class => "row_label", :content => "Website")
      response.should have_selector("a", :href => "http://the.re", :content => "the.re")
      response.should have_selector("a", :href => "http://here.it.is", :content => "More information about member_name MP")
    end
    
    it "should not render missing data" do
      assign(:constituency, @other_constituency)
      render(:template => "constituencies/show.html")
      view.should render_template(:"_member")
      view.should render_template(:"_constituency")
      view.should render_template(:show)
      
      response.should have_selector("div", :class => "row_value", :content => "member_name")
      response.should_not have_selector("a", :content => "member_name")
      response.should_not have_selector("a", :content => "More information about member_name MP")
      response.should_not have_selector("div", :class => "row_label", :content => "Website")
    end
    
    it "should show no sitting member text if no sitting member" do
      constituency = Constituency.new()
      constituency.member_visible = false
      constituency.stub!(:friendly_id).and_return 'islington_south'
      assign(:constituency, constituency)
      render(:template => "constituencies/show.html")
      view.should render_template(:"_member")
      view.should render_template(:"_constituency")
      view.should render_template(:show)
      
      response.should have_selector("p", :content => "There is no sitting Member of Parliament for this constituency.")
    end
  end
  
  describe "when given a list of constituencies" do
    it 'should handle hidden and visible members properly' do
      @constituency.stub!(:member_visible).and_return false
      assign(:constituency, nil)
      assign(:constituencies, [@constituency, @other_constituency])
      assign(:members, [])
      render(:template => "constituencies/show.html")
      view.should render_template(:"_constituency_match")
      view.should render_template(:"_constituency")
      view.should render_template(:show)
      
      response.should have_selector("h4", :content => "2 Constituencies")
      response.should have_selector("a", :href => "/constituencies/islington_north", :content => "Islington North")
      response.should have_selector("p", :content => "no sitting Member")
      response.should have_selector("a", :href => "/constituencies/islington_south", :content => "Islington South")
      response.should have_selector("p", :content => "member_name")
    end
  end
end
