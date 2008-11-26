Feature: Find MP from postcode
  In order to contact my MP
  as a constituent
  want to find my MP using my postcode

  Scenario: Enter postcode that has a constituency and an MP name
    Given I am on the Front page
    Then I should see "First, type your UK postcode:"
    When I search for "AB101AA"
    Then I should see "Aberdeen North"
    And I should see "Frank Doran"

  Scenario: Enter postcode that has a constituency with no MP name
    Given I am on the Front page
    When I search for "KY8 5XY"
    Then I should see "Glenrothes"
    And I should see "No recorded member."

  Scenario: Enter bogus postcode
    Given I am on the Front page
    When I search for "N1 XXX"
    Then I should see "No matches found for N1 XXX."

  Scenario: Enter Guernsey postcode
    Given I am on the Front page
    When I search for "GY1 1AB"
    Then I should see "No constituency found."
