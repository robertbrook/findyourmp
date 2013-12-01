When /^I search for "(.*)"$/ do |search_term|
  within '#search' do
    fill_in("q", :with => search_term)
  end
  And 'I press "Find MP"'
end

Given /I am on the Front page/ do
  visit "/"
end
