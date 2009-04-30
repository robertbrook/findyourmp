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
    Then I should see html "Sorry: we couldn't find a constituency when we searched for <code>Tamaki</code>."

  Scenario: Enter part of a valid constituency name that returns multiple results
    Given I am on the Front page
    When I search for "Aberdeen"
    Then I should see html "<strong class="highlight">Aberdeen</strong> North"
    And I should see html "<strong class="highlight">Aberdeen</strong> South"
    And I should see "Frank Doran"
    And I should see "Miss Anne Begg"
    When I follow "Aberdeen South"
    Then I should see "Aberdeen South"
    And I should see "Miss Anne Begg"

  Scenario: Enter a partial constituency name that returns a single result
    Given I am on the Front page
    When I search for "North"
    Then I should see "Aberdeen North"
    And I should not see "Aberdeen South"
    And I should see "Frank Doran"
    And I should see "Email Frank Doran"
    And I should not see "Edit"

  Scenario: Enter a valid constituency with no sitting MP
    Given I am on the Front page
    When I search for "Glenrothes"
    Then I should see "Glenrothes"
    And I should see "There is no sitting Member of Parliament for this constituency."

  Scenario: Enter a single letter search term
    Given I am on the Front page
    When I search for "a"
    Then I should see "Sorry: we need more than two letters to search"
    And I should not see "berdeen North"
    And I should not see "berdeen South"

  Scenario: Enter a single letter search term
    Given I am on the Front page
    When I search for "ab"
    Then I should see "Sorry: we need more than two letters to search"
    And I should not see "erdeen North"
    And I should not see "erdeen South"

  Scenario: Enter a single letter search term
    Given I am on the Front page
    When I search for "abe"
    Then I should see html "<strong class="highlight">Abe</strong>rdeen North</a>"
    And I should see html "<strong class="highlight">Abe</strong>rdeen South</a>"

  Scenario: Enter a constituency name that returns no results
    Given I am on the Front page
    When I search for "Isle of Wight"
    Then I should see html "Sorry: we couldn't find a constituency when we searched for <code>Isle of Wight</code>."
