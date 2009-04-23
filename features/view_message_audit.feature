Feature: View message audit
  In order to monitor the service
  as an editing user
  want to view the message audit

  Scenario: Look at admin home page
    Given I am logged in as an editing user
    And I am on the Front page
    When I follow "Admin home"
    Then I should see "Messages sent"
    And I should see "Messages waiting to be sent"
    And I should see "Edit your account settings"
    And I should not see "Add new user"
    And I should not see "Edit users"

  Scenario: Look at message audit errors
    Given I am on the Admin Home Page as an editing user
    When I follow "Messages waiting to be sent"
    Then I should see "January 2009"
    And I should see "2"

  Scenario: Look at messages by constituency
    Given I am on the Admin Home Page as an editing user
    When I follow "Messages sent"
    Then I should see "February 2009"
    And I should see "2"

