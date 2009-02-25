Feature: Search API
  In order to search using the API
  as a constituent
  I want to get data via the API

  Scenario: Call search API with valid postcode, requesting XML
    Given I call the search API searching for "AB101AA" and requesting "xml"
    Then I should see "<postcode>"
    And I should see "<code>AB10 1AA</code>"
    And I should see "<constituency-name>Aberdeen North</constituency-name>"
    And I should see "<member>Frank Doran</member>"

  Scenario: Call search API with valid constituency name, requesting XML
    Given I call the search API searching for "Aberdeen South" and requesting "xml"
    Then I should see "<constituency>"
    And I should see "<constituency-name>Aberdeen South</constituency-name>"
    And I should see "<member-name>Miss Anne Begg</member-name>"
    And I should see "<member-party></member-party>"
    And I should see "<member-biography-url></member-biography-url>"
    And I should see "<member-website></member-website>"

  Scenario: Call search API with valid constituency name (but no MP), requesting XML
    Given I call the search API searching for "Glenrothes" and requesting "xml"
    Then I should see "<constituency>"
    And I should see "<constituency-name>Glenrothes</constituency-name>"
    And I should see "<member-name>No sitting member</member-name>"
    And I should see "<member-party></member-party>"
    And I should see "<member-biography-url></member-biography-url>"
    And I should see "<member-website></member-website>"

  Scenario: Call search API with partial member name which will return more than 1 result line, requesting XML
    Given I call the search API searching for "Frank" and requesting "xml"
    Then I should see "<results>"
    And I should see "<constituency-name>Aberdeen North</constituency-name>"
    And I should see "<member-name>Frank Doran</member-name>"
    And I should see "<constituency-name>Motherwell and Wishaw</constituency-name>"
    And I should see "<member-name>Mr Frank Roy</member-name>"

  Scenario: Call search API with an invalid search term, requesting XML
    Given I call the search API searching for "invalid" and requesting "xml"
    Then I should see "<error>"

  Scenario: Call search API to return a single record where the constituency name contains a "&" character, requesting XML
    Given I call the search API searching for "Newry" and requesting "xml"
    Then I should see "<constituency>"
    And I should see "<constituency-name>Newry &amp; Armagh</constituency-name>"

  Scenario: Call search API with postcode prefix, requesting XML
    Given I call the search API searching for "BT35" and requesting "xml"
    Then I should see "<results>"
    And I should see "<constituency-matches>"
    And I should see "<constituency-name>Upper Bann</constituency-name>"
    And I should see "<constituency-name>Newry &amp; Armagh</constituency-name>"
