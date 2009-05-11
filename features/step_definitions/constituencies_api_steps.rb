require 'uri'

Given /^I call the constituencies API with an ONS id of "(.+)", requesting "(.+)"$/ do |ons_id, format|
  visit URI.escape("/api/constituencies?ons_id=#{ons_id}&format=#{format}")
end

Given /^I call the constituencies API with a member name of "(.+)", requesting "(.*)"$/ do |member, format|
  visit URI.escape("/api/constituencies?member=#{member}&format=#{format}")
end

Given /^I call the constituencies API with a constituency name of "(.+)", requesting "(.*)"$/ do |constituency, format|
  visit URI.escape("/api/constituencies?constituency=#{constituency}&format=#{format}")
end

Given /^I call the constituencies API with no parameters, requesting "(.*)"$/ do |format|
  visit URI.escape("/api/constituencies/?format=#{format}")
end