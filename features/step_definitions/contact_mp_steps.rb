Before do
  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'
end

Given /^my MP is contactable via email$/ do
  # puts 'set email for constituency'
end

Given /I am on my Postcode page/ do
  visits "/postcodes/AB101AA"
end

Given /I am on a new Message page/ do
  Given "I am on my Postcode page"
  And 'I follow "Send a message to Frank Doran"'
end

Given /I am on a preview Message page/ do
  Given "I am on a new Message page"
  And 'I preview message'
end

When /^I preview message without "(.*)"$/ do |field|
  When %Q|I fill in "Your email address" with "here@now.earth"| unless field == 'Your email address'
  When %Q|I fill in "Your full name" with "Micky Muse"| unless field == 'Your full name'
  When %Q|I fill in "Your postal address" with "1 Way Out"| unless field == 'Your postal address'
  When %Q|I fill in "Your postcode" with "AB101AA"| unless field == 'Your postcode'
  When %Q|I fill in "Your subject" with "Problem"| unless field == 'Your subject'
  When %Q|I fill in "Your message" with "Question"| unless field == 'Your message'
  And 'I press "Preview your message"'
end

When /^I preview message$/ do
  When %Q|I fill in "Your email address" with "here@now.earth"|
  When %Q|I fill in "Your full name" with "Micky Muse"|
  When %Q|I fill in "Your postal address" with "1 Way Out"|
  When %Q|I fill in "Your postcode" with "AB101AA"|
  When %Q|I fill in "Your subject" with "Problem"|
  When %Q|I fill in "Your message" with "Question"|
  And 'I press "Preview your message"'
end

When /^I re-edit message$/ do
  And 'I press "Re-edit your message"'
end
