Feature: End of Parliament handling
  In order to handle the end of a Parliament
  as a an admin user
  I want to hide all members' details

  Scenario: Hide all member details
    Given I am logged in as an admin user
    And I am on the Constituency index page
    When I press "Hide all members"
    Then I should see all MPs marked hidden

  Scenario: Hide all member details
    Given I am logged in as an admin user
    And I am on the Constituency index page
    When I press "Unhide all members"
    Then I should see all MPs not marked hidden
