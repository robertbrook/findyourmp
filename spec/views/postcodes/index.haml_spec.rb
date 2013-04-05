require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/search_spec_helper'

describe "/postcodes/index.haml" do
  before do
    @controller.stub!(:current_user).and_return nil
    @template = "postcodes/index.html"
    @layout = 'application'
    assign(:postcode_count, 1000000)
    assign(:constituency_count, 640)
  end

  it_should_behave_like "renders search form"
end
