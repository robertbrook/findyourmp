require './spec/spec_helper'
require './spec/views/postcodes/search_spec_helper'

describe "/postcodes/show.haml" do
  before do
    @template = 'postcodes/show.haml'
    @layout = 'application'
    assigns[:postcode] = mock_model(Postcode, :code_with_space=>'GY1 1AA')
    assigns[:constituency] = nil
    @controller.stub!(:current_user).and_return nil
    template.stub!(:postcode_format_links).and_return ''
  end

  def do_render
    @layout ? render(@template, :layout=>@layout) : render(@template)
  end

  describe 'when there is no constituency' do
    it 'should show no consituency found warning' do
      do_render
      response.should have_tag("p",'No constituency found.')
    end
  end
end
