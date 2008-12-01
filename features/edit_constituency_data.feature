Feature: Contact MP
  In order to have correct information on website
  as a admin user
  want to edit consitunency and member data

  Scenario: Follow the "edit" link from constituency page
    Given I am logged in as an admin user
    And I am on a Constituency page
    When I follow "edit"
    Then I should see "Edit constituency"
    Then I should see "Constituency"
    Then I should see "Member"
    Then I should see "Member party"
    Then I should see "Member email"
    Then I should see "Member biography url"
    Then I should see "Member website"
    Then I should see "Member visible"

