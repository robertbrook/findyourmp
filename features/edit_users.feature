Feature: View message audit
  In order to maintain the service
  as a admin user
  want to edit user accounts

  Scenario: Look at admin home page
    Given I am logged in as an admin user
    And I am on the Front page
    When I follow "Show admin home"
    Then I should see "Add new user"
    And I should see "Edit users"
    And I should see "Edit your account settings"

  Scenario: Look at message audit summary
    Given I am on the Admin Home page as an admin user
    When I follow "Add new user"
    Then I should see "Register user"
    Then I should see "Login"
    Then I should see "Password"
    Then I should see "Password confirmation"
    Then I should see "Email"
    Then I should see "Admin privileges"
    Then I should see "Create user"

  Scenario: Create user with compulsory field missing and see detailed warning
    Given I am on a new User page
    When I save a user without "Email"
    Then I should see "Email is too short"

  More Examples:
    | field_missing         | warning_message                       |
    | Login                 | Login is too short                    |
    | Password              | Password is too short                 |
    | Password confirmation | Password doesn't match confirmation   |

