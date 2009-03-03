
Given /^I am on the Admin Home Page as an editing user$/ do
  Given 'I am logged in as an editing user'
  And 'I am on the Front page'
  When 'I follow "Show admin home"'
end

