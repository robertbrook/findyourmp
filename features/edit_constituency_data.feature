Feature: Edit constituency data
  In order to have correct information on website
  as a admin user
  want to edit constituency and member data

  Scenario: Follow the "edit" link from constituency page
    Given I am logged in as an admin user
    And I follow "All constituencies"
    And I follow "Aberdeen North"
    Then I should see Edit Constituency Form

  Scenario: Edit constituency and member details
    Given I am logged in as an admin user
    And I am on the Constituency edit page for "Aberdeen North"
    When I fill in "Constituency" with "Aberdeen East"
    And I fill in "Member" with "William Wallace"
    And I fill in "Member party" with "SNP"
    And I fill in "Member email" with "bill@parl.uk"
    And I fill in "Member biography url" with "http://the.re"
    And I fill in "Member website" with "http://it.is"
    And I press "Update"
    Then I should see "Aberdeen East"
    And I should see "William Wallace (SNP)"
    And I should see link to "http://the.re"
    And I should see link to "http://it.is"
    And I should see "Email William Wallace"

  Scenario: Edit member email to be empty
    Given I am logged in as an admin user
    And I am on the Constituency edit page for "Aberdeen North"
    When I fill in "Member email" with ""
    And I press "Update"
    Then I should see "Frank Doran"
    And I should see "Sorry, we do not have an email address for Frank Doran."
    And I should not see "Email Frank Doran"

  Scenario: Set member requested contact url
    Given I am logged in as an admin user
    And I am on the Constituency edit page for "Aberdeen North"
    When I fill in "Requested contact url" with "http://member.requested.url/"
    And I press "Update"
    Then I should see "Frank Doran"
    And I should see "Contact Frank Doran"

