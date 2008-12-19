Feature: Find MP from partial constituency name
  In order to contact my MP
  as a constituent
  want to find my MP using a partial constituency name

  Scenario: Enter a partial constituency name
    Given I am on the Front page
    When I search for "North"
    Then I should see "Aberdeen North"
    And I should see "Frank Doran"
