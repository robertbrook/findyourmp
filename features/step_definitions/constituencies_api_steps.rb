Given /^I call the constituencies API with an ONS id of "(.+)", requesting "(.+)"$/ do |ons_id, format|
  visits "/api/constituencies?ons_id=#{ons_id}&format=#{format}"
end

Given /^I call the constituencies API with a member name of "(.+)", requesting "(.*)"$/ do |member, format|
  visits "/api/constituencies?member=#{member}&format=#{format}"
end

Given /^I call the constituencies API with a constituency name of "(.+)", requesting "(.*)"$/ do |constituency, format|
  visits "/api/constituencies?constituency=#{constituency}&format=#{format}"
end

Given /^I call the constituencies API with no parameters$/ do
  visits "/api/constituencies/"
end