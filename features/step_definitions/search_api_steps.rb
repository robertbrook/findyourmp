Given /^I call the search API searching for "(.+)" and requesting "(.+)"$/ do |search_term, format|
  visit URI.escape("/api/search?search_term=#{search_term}&format=#{format}")
end