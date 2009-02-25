
Given /^I am on the Admin Home Page as an editing user$/ do
  Given 'I am logged in as an editing user'
  And 'I am on the Front page'
  When 'I follow "Show admin home"'
end

Given /^I am on the Admin Home page as an admin user$/ do
  Given 'I am logged in as an admin user'
  And 'I am on the Front page'
  When 'I follow "Show admin home"'
end

