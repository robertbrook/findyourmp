require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/search_spec_helper'

describe "/postcodes/index.haml" do
  before do
    @template = 'postcodes/index.haml'
  end
  it_should_behave_like "renders search form"
end
