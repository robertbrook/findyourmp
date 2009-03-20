Feature: Find MP from partial constituency name
  In order to edit MP details
  as a admin user
  want to find an MP using a partial constituency name

  Scenario: Enter a partial constituency name
    Given I am logged in as an admin user
    And I am on the Front page
    When I search for "North"
    Then I should not see "Aberdeen North"
    And I should not see "Aberdeen South"
    And I should see "Aberdeen North"
    And I should see "Frank Doran"
    And I should see "Send a message to Frank Doran"
    And I should see "Edit"
