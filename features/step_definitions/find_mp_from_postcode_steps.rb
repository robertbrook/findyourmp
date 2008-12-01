Before do
  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'

  Given 'there is a postcode "KY8 5XY" in constituency "Glenrothes"'
  Given 'there is no MP in constituency "Glenrothes"'

  Given 'there is a postcode "GY1 1AB" with no constituency'
end

After do
end

When /^I search for "(.*)"$/ do |postcode_code|
  When "I fill in \"search_term\" with \"#{postcode_code}\""
  And 'I press "Search"'
end

Given /^there is a postcode "(.*)" with no constituency$/ do |postcode_code|
  Postcode.find_or_create_by_code_and_constituency_id(postcode_code.gsub(' ','').strip, 900)
end

Given /^there is a postcode "(.*)" in constituency "(.*)"$/ do |postcode_code, constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  Postcode.find_or_create_by_code_and_constituency_id(postcode_code.gsub(' ','').strip, constituency.id)
end

Given /^there is an MP "(.*)" in constituency "(.*)"$/ do |member_name, constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  constituency.member_name = member_name
  constituency.member_visible = true
  constituency.save
end

Given /^there is no MP in constituency "(.*)"$/ do |constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  if constituency.member_name
    constituency.member_name = nil
    constituency.save
  end
end

Given /I am on the Front page/ do
  visits "/"
end
