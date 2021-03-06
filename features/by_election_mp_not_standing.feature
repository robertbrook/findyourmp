Feature: By-election handling when previous MP not standing
  In order to handle a by-election being called
  as a an admin user
  I want to delete the constituency's member details

  Scenario: Remove member details
    Given I am logged in as an admin user
    And I am on the Constituency edit page for "Aberdeen North"
    When I clear "Member"
    And I press "Update"
    Then I should see the "Aberdeen North" constituency page without "Frank Doran"
    And I should see "There is no sitting Member of Parliament for this constituency."
