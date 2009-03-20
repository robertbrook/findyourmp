Given /^I call the postcodes API with "(.+)", requesting "(.+)"$/ do |code, format|
  visit "/api/postcodes?code=#{code}&format=#{format}"
end

Given /^I call the postcodes API with district "(.+)", requesting "(.*)"$/ do |district, format|
  visit "/api/postcodes?district=#{district}&format=#{format}"
end