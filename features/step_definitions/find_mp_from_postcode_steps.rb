
Given /^there is a postcode "(.*)" in constituency "(.*)"$/ do |postcode_code, constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  Postcode.find_or_create_by_code_and_constituency_id(postcode_code, constituency.id)
end

Given /I am on the Front page/ do
  visits "/"
end


