Given /^I call the postcodes API with "(.+)", requesting "(.+)"$/ do |code, format|
  visits "/api/postcodes?code=#{code}&format=#{format}"
end

Given /^I call the postcodes API with district "(.+)", requesting "(.*)"$/ do |district, format|
  visits "/api/postcodes?district=#{district}&format=#{format}"
end