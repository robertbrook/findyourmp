Given /^I am on the Constituency index page$/ do
  Given 'I am on the Front page'
  And "I follow \"All constituencies\""
end

Then /^I should see all MPs marked hidden$/ do
  Then 'I should see "Frank Doran \(hidden\)"'
  And 'I should see "Miss Anne Begg \(hidden\)"'
end

Then /^I should see all MPs not marked hidden$/ do
  Then 'I should not see "Frank Doran \(hidden\)"'
  And 'I should not see "Miss Anne Begg \(hidden\)"'
  And 'I should see "Frank Doran"'
  And 'I should see "Miss Anne Begg"'
end
