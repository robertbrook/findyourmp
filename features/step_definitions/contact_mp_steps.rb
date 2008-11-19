Before do
  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'
end

Given /^my MP is contactable via email$/ do
  # puts 'set email for constituency'
end

Given /I am on a Postcode page/ do
  visits "/postcodes/AB101AA"
end


