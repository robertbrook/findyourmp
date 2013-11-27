require './spec/spec_helper'

describe "/constituencies/new.haml" do

  before do
    @constituency = mock_model(Constituency)
    @constituency.stub!(:new_record?).and_return(true)
    @constituency.stub!(:name).and_return("MyString")
    assigns[:constituency] = @constituency
  end

  it "should render new form" do
    render "/constituencies/new.haml"

    response.should have_tag("form[action=?][method=post]", constituencies_path) do
      with_tag("input#constituency_name[name=?]", "constituency[name]")
    end
  end
end
