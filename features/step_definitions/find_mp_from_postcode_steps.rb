
Given /^there is a postcode "(.*)" with no constituency$/ do |postcode_code|
  Postcode.find_or_create_by_code_and_constituency_id(postcode_code.gsub(' ','').strip, 900)
end

Given /^there is a postcode "(.*)" in constituency "(.*)"$/ do |postcode_code, constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  Postcode.find_or_create_by_code_and_constituency_id(postcode_code.gsub(' ','').strip, constituency.id)
end

Given /^there is an MP "(.*)" in constituency "(.*)"$/ do |member_name, constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  unless constituency.member_name == member_name
    constituency.member_name = member_name
    constituency.save
  end
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


