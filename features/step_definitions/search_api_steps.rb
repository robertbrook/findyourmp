Given /^I call the search API searching for "(.+)" and requesting "(.+)"$/ do |search_term, format|
  visit URI.escape("/api/search/?q=#{search_term}&f=#{format}")
end