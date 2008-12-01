Feature: By-election handling when previous MP standing
  In order to handle a by-election being called
  as a an admin user
  I want to hide the constituency's member details

  Scenario: Hide member details
    Given I am logged in as an admin user
    And I am on the Constituency edit page for "Aberdeen North"
    When I uncheck "Member visible"
    And I press "Update"
    Then I should see the "Aberdeen North" constituency page without "Frank Doran"
    And I should see "No sitting member."
