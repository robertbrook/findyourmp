Feature: Find MP from MP name
  In order to contact my MP
  as a constituent
  I want to find my MP using my their name

  Scenario: Enter a valid MP name
    Given I am on the Front page
    When I search for "Frank Doran"
    Then I should see "Aberdeen North"
    And I should see "Frank Doran"

  Scenario: Enter an invalid MP name
    Given I am on the Front page
    When I search for "Tamaki"
    Then I should see "No matches found for Tamaki."

  Scenario: Enter part of a valid MP name
    Given I am on the Front page
    When I search for "Frank"
	Then I should see "<strong class="highlight">Frank</strong> Cook"
    And I should see "<strong class="highlight">Frank</strong> Doran"
	When I follow "<strong class="highlight">Frank</strong> Doran"
    Then I should see "Aberdeen North"
    And I should see "Frank Doran"
