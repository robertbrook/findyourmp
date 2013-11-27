require './spec/spec_helper'
require './spec/views/postcodes/search_spec_helper'

describe "/postcodes/index.haml" do
  before do
    @controller.stub!(:current_user).and_return nil
    @template = 'postcodes/index.haml'
    @layout = 'application'
    assigns[:postcode_count] = 1000000
    assigns[:constituency_count] = 640
  end

  it_should_behave_like "renders search form"

end
