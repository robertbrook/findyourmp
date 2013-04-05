require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/search_spec_helper'

describe "/postcodes/show.haml" do
  before do
    postcode = mock(Postcode, :code_with_space=>'GY1 1AA')
    assign(:postcode, postcode)
    @controller.stub!(:current_user).and_return nil
    view.stub!(:postcode_format_links).and_return ''
  end

  describe 'when there is no constituency' do
    it 'should show no consituency found warning' do
      render(:template => "postcodes/show.html")
      response.should have_selector('p', :content => 'No constituency found')
    end
  end
end
