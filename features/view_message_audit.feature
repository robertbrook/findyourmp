Feature: View message audit
  In order to monitor the service
  as an editing user
  want to view the message audit

  Scenario: Look at message audit summary
    Given I am logged in as an editing user
    And I am on the Front page
    When I follow "Show admin home"
    Then I should see "Sent messages"
    And I should see "Attempted to send messages"
    And I should not see "Add new user"

  Scenario: Look at message audit errors
    Given I am on the Admin Home Page as an editing user
    When I follow "Attempted to send messages"
    Then I should see "January 2009"
    And I should see "1"
    And I should see "535 5.7.8 Error: authentication failed: authentication failure"

  Scenario: Look at messages by constituency
    Given I am on the Admin Home Page as an editing user
    When I follow "Sent messages"
    Then I should see "February 2009"
    And I should see "1"

