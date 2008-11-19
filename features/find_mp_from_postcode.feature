Feature: Find MP from postcode
  In order to contact my MP
  as a constituent
  want to find my MP using my postcode

  Scenario: Enter postcode that has a constituency and an MP name
    Given I am on the Front page
    And there is a postcode "AB101AA" in constituency "Aberdeen North"
    And there is an MP "Frank Doran" in constituency "Aberdeen North"
    When I fill in "search_term" with "AB101AA"
    And I press "Search"
    Then I should see "Aberdeen North"
    And I should see "Frank Doran"

  Scenario: Enter postcode that has a constituency with no MP name
    Given I am on the Front page
    And there is a postcode "KY8 5XY" in constituency "Glenrothes"
    And there is no MP in constituency "Glenrothes"
    When I fill in "search_term" with "KY8 5XY"
    And I press "Search"
    Then I should see "Glenrothes"
    And I should see "NO RECORDED MEMBER"

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

