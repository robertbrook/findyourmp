Feature: Find MP from constituency name
  In order to contact my MP
  as a constituent
  want to find my MP using my constituency name

  Scenario: Enter a valid constituency name
    Given I am on the Front page
    When I search for "Aberdeen North"
    Then I should see "Aberdeen North"
    And I should see "Frank Doran"

  Scenario: Enter an invalid constituency name
    Given I am on the Front page
    When I search for "Tamaki"
    Then I should see "No matches found for Tamaki."

  Scenario: Enter part of a valid constituency name that returns multiple results
    Given I am on the Front page
    When I search for "Aberdeen"
    Then I should see "<strong class="highlight">Aberdeen</strong> North"
    And I should see "<strong class="highlight">Aberdeen</strong> South"
    And I should see "\(Frank Doran\)"
    And I should see "\(Miss Anne Begg\)"
    When I follow "<strong class="highlight">Aberdeen</strong> South"
    Then I should see "Aberdeen South"
    And I should see "Miss Anne Begg"

  Scenario: Enter a partial constituency name that returns a single result
    Given I am on the Front page
    When I search for "North"
    Then I should see "Aberdeen North"
    And I should not see "Aberdeen South"
    And I should see "Frank Doran"
    And I should see "Send a message to Frank Doran"
    And I should not see "Edit"
