Feature: View message audit
  In order to monitor the service
  as a admin user
  want to view the message audit

  Scenario: Look at message audit summary
    Given I am logged in as an admin user
    And I am on the Front page
    When I follow "Show message audit"
    Then I should see "Sent messages"
    And I should see "Attempted to send messages"
    And I should see "Draft messages"

  Scenario: Look at message audit details
    Given I am on the Message Audit Page
    When I follow "Sent messages"

