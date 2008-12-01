Before do
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

