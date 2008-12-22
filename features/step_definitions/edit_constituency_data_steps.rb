After do
  Constituency.delete_all
  Postcode.delete_all
  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'
end

Given /^I am logged in as an admin user$/ do
  Given 'I am on the Front page'
  And 'I press "Enable ADMINISTRATOR functions"'
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
