
Given /^I am on the Admin Home page as an admin user$/ do
  Given 'I am logged in as an admin user'
  And 'I am on the Front page'
  And 'I follow "Show admin home"'
end

Given /^I am on a new User page$/ do
  Given 'I am on the Admin Home page as an admin user'
  And 'I follow "Add new user"'
end

When /^I save a user without "(.*)"$/ do |field|
  When %Q|I fill in "Email" with "here@now.earth"| unless field == 'Email'
  And %Q|I fill in "Login" with "user_name"| unless field == 'Login'
  And %Q|I fill in "Password" with "123456"| unless field == 'Password'
  And %Q|I fill in "Password confirmation" with "123456"| unless field == 'Password confirmation'
  And 'I press "Create user"'
end

