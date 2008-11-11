require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/search_spec_helper'

describe "/postcodes/show.haml" do
  before do
    @template = 'postcodes/show.haml'
    @layout = 'application'
    assigns[:postcode] = mock_model(Postcode, :code_with_space=>'GY1 1AA')
    assigns[:constituency] = nil
    template.stub!(:postcode_format_links).and_return ''
  end

  it_should_behave_like "renders search form"

  describe 'when there is no constituency' do
    it 'should show no consituency found warning' do
      do_render
      response.should have_tag("p",'No constituency found.')
    end
  end
end
