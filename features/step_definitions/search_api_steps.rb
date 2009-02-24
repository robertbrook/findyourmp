Given /^I call the search API searching for "(.+)" and requesting "(.+)"$/ do |search_term, format|
  visits "/api/search?search_term=#{search_term}&format=#{format}"
end