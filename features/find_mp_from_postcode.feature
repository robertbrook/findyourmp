Feature: Find MP from postcode
  In order to contact my MP
  as a constituent
  want to find my MP using my postcode

  Scenario: Enter postcode that has a constituency and an MP name
    Given there is a postcode "AB101AA" in constituency "Aberdeen North"
    Given I am on the Front page
    When I fill in "search_term" with "AB101AA"
    And I press "Search"
    Then I should see "Aberdeen North"

  Scenario: Enter bogus postcode
    Given I am on the Front page
    When I fill in "search_term" with "N1 XXX"
    And I press "Search"
    Then I should see "No matches found for N1 XXX."

  Scenario: Enter Guernsey postcode
    Given there is a postcode "GY1 1AB" with no constituency
    Given I am on the Front page
    When I fill in "search_term" with "GY1 1AB"
    And I press "Search"
    Then I should see "No constituency found."

