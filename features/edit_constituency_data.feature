Feature: Contact MP
  In order to have correct information on website
  as a admin user
  want to edit constituency and member data

  Scenario: Follow the "edit" link from constituency page
    Given I am logged in as an admin user
    And I am on a Constituency page
    When I follow "edit"
    Then I should see Edit Constituency Form
