shared_examples_for "returns in correct format" do
  it 'should return xml when passed format=xml' do
    do_get 'xml'
    response.content_type.should == "application/xml"
  end

  it 'should return json when passed format=json' do
    do_get 'json'
    response.content_type.should == "application/json"
  end

  it 'should return text when passed format=text' do
    do_get 'text'
    response.content_type.should == "text/plain"
  end

  it 'should return csv when passed format=csv' do
    do_get 'csv'
    response.content_type.should =='text/csv'
  end

  it 'should return yaml when passed format=yaml' do
    do_get 'yaml'
    response.content_type.should =='application/x-yaml'
  end
end