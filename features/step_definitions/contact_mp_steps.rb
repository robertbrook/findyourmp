Before do
  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'
  
  Given 'there is a postcode "ML14BW" in constituency "Motherwell and Wishaw"'
  Given 'there is an MP "Mr Frank Roy" in constituency "Motherwell and Wishaw"'
end

Then /^I should see Message Form$/ do
  Then 'I should see "Your email address"'
  And 'I should see "Your full name"'
  And 'I should see "Your postal address"'
  And 'I should see "Your postcode"'
  And 'I should see "Your subject"'
  And 'I should see "Your message"'
  And 'I should see "Preview your message"'
end

Given /^my MP is contactable via email$/ do
  constituency = Constituency.find_or_create_by_name("Aberdeen North")
  if constituency.member_email.blank?
    constituency.member_email = "frank_doran@parl.uk"
    constituency.save
  end
end

Given /^the MP in constituency "(.*)" is not contactable via email$/ do |constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  constituency.member_email = ""
  constituency.save
end

Given /I am on my Postcode page/ do
  visits "/postcodes/AB101AA"
end

Given /I am on my Constituency page/ do
  Given 'I am on the Front page'
  And 'I search for "Aberdeen North"'
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
  And %Q|I fill in "Your full name" with "Micky Muse"| unless field == 'Your full name'
  And %Q|I fill in "Your postal address" with "1 Way Out"| unless field == 'Your postal address'
  And %Q|I fill in "Your postcode" with "AB101AA"| unless field == 'Your postcode'
  And %Q|I fill in "Your subject" with "Problem"| unless field == 'Your subject'
  And %Q|I fill in "Your message" with "Question"| unless field == 'Your message'
  And 'I press "Preview your message"'
end

When /^I fill in valid message$/ do
  And %Q|I fill in "Your full name" with "Micky Muse"|
  And %Q|I fill in "Your postal address" with "1 Way Out"|
  And %Q|I fill in "Your postcode" with "AB101AA"|
  And %Q|I fill in "Your subject" with "Problem"|
  And %Q|I fill in "Your message" with "Question"|
end

When /^I preview message with an invalid sender email$/ do
  When %Q|I fill in "Your email address" with "bad_address"|
  And 'I fill in valid message'
  And 'I press "Preview your message"'
end

When /^I preview message$/ do
  When %Q|I fill in "Your email address" with "here@now.earth"|
  When 'I fill in valid message'
  And 'I press "Preview your message"'
end

When /^I re-edit message$/ do
  When 'I press "Re-edit your message"'
end

When /^I send message$/ do
  When 'I press "Send message"'
end
