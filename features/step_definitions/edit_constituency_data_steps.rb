Given /^I am logged in as an editing user$/ do
  Given 'I am on the Front page'
  And 'I follow "Log In"'
  And 'I fill in "User name" with "editor"'
  And 'I fill in "Password" with "editor"'
  And 'I press "Login"'
end

Given /^I am logged in as an admin user$/ do
  Given 'I am on the Front page'
  And 'I follow "Log In"'
  And 'I fill in "User name" with "admin"'
  And 'I fill in "Password" with "admin"'
  And 'I press "Login"'
end

Given /^I am on a Edit Constituency page$/ do
  Given 'I am logged in as an admin user'
  And 'I follow "Edit constituencies"'
  And 'I follow "Aberdeen North"'
end

Given /^I am on the Constituency edit page for "(.+)"$/ do |constituency_name|
  Given 'I follow "Edit constituencies"'
  And "I follow \"#{constituency_name}\""
end

Then /^I should see the "(.+)" constituency page without "(.+)"$/ do |constituency_name, member_name|
  Then "I should see \"#{constituency_name}\""
  And "I should not see \"#{member_name}\""
end

Then /^I should see Edit Constituency Form$/ do
  Then 'I should see "Edit constituency"'
  And 'I should see "Constituency ID"'
  And 'I should see "Constituency"'
  And 'I should see "Member"'
  And 'I should see "Member party"'
  And 'I should see "Member email"'
  And 'I should see "Member biography URL"'
  And 'I should see "Member website"'
  And 'I should see "Member visible"'
end
