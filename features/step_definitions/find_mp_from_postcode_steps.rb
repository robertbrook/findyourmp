When /^I search for "(.*)"$/ do |postcode_code|
  When "I fill in \"search_term\" with \"#{postcode_code}\""
  And 'I press "Find MP"'
end

Given /I am on the Front page/ do
  visit "/"
end
