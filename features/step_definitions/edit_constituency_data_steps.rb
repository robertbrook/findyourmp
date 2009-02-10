Given /^I am logged in as an admin user$/ do
  Given 'I am on the Front page'
  And 'I follow "Log In"'
  And 'I fill in "User name" with "admin"'
  And 'I fill in "Password" with "admin"'
  And 'I press "Login"'
end

Given /I am on a Constituency page/ do
  Given 'I am on the Front page'
  And 'I search for "Aberdeen North"'
end

Given /^I am on a Edit Constituency page$/ do
  Given 'I am logged in as an admin user'
  And 'I am on a Constituency page'
  When 'I follow "edit"'
end

Then /^I should see Edit Constituency Form$/ do
  Then 'I should see "Edit constituency"'
  And 'I should see "Constituency ID"'
  And 'I should see "Constituency"'
  And 'I should see "Member"'
  And 'I should see "Member party"'
  And 'I should see "Member email"'
  And 'I should see "Member biography url"'
  And 'I should see "Member website"'
  And 'I should see "Member visible"'
end
