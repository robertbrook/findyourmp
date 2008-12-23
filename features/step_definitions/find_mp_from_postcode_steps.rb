When /^I search for "(.*)"$/ do |postcode_code|
  When "I fill in \"search_term\" with \"#{postcode_code}\""
  And 'I press "Search"'
end

Given /I am on the Front page/ do
  visits "/"
end
