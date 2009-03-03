Feature: Search API
  In order to search using the API
  as a constituent
  I want to get data via the search API

  Scenario: Call search API with valid postcode, requesting XML
    Given I call the search API searching for "AB101AA" and requesting "xml"
    Then I should see "<postcode>"
    And I should see "<code>AB10 1AA</code>"
    And I should see "<constituency-name>Aberdeen North</constituency-name>"
    And I should see "<member>Frank Doran</member>"
    And I should see "/postcodes/AB101AA.xml</uri>"

  Scenario: Call search API with valid postcode, requesting plain text
    Given I call the search API searching for "AB101AA" and requesting "text"
    Then I should see "postcode: AB10 1AA"
    And I should see "constituency_name: Aberdeen North"
    And I should see "member_name: Frank Doran"
    And I should see "/postcodes/AB101AA.txt"

  Scenario: Call search API with valid postcode, requesting JSON
    Given I call the search API searching for "AB101AA" and requesting "json"
    Then I should see "\{\"postcode\": \{\"code\": \"AB10 1AA\", \"constituency_name\": \"Aberdeen North\", \"member_name\": \"Frank Doran\", \"uri\": "
    And I should see "/postcodes/AB101AA.json"

  Scenario: Call search API with valid postcode, requesting CSV
    Given I call the search API searching for "AB101AA" and requesting "csv"
    Then I should see "postcode,constituency_name,member_name,uri\n"
    And I should see "\"AB10 1AA\",\"Aberdeen North\",\"Frank Doran\""
    And I should see "/postcodes/AB101AA.csv"

  Scenario: Call search API with valid constituency name, requesting XML
    Given I call the search API searching for "Aberdeen South" and requesting "xml"
    Then I should see "<constituency>"
    And I should see "<constituency-name>Aberdeen South</constituency-name>"
    And I should see "<member-name>Miss Anne Begg</member-name>"
    And I should see "<member-party></member-party>"
    And I should see "<member-biography-url></member-biography-url>"
    And I should see "<member-website></member-website>"
    And I should see "/constituencies/aberdeen-south.xml</uri>"

  Scenario: Call search API with valid constituency name, requesting JSON
    Given I call the search API searching for "Aberdeen South" and requesting "json"
    Then I should see "\{\"constituency\": \{"
    And I should see "\"constituency_name\": \"Aberdeen South\""
    And I should see "\"member_name\": \"Miss Anne Begg\""
    And I should see "\"member_party\": \"\""
    And I should see "\"member_biography_url\": \"\""
    And I should see "\"member_website\": \"\""
    And I should see "\"uri\": "
    And I should see "/constituencies/aberdeen-south.json"

  Scenario: Call search API with valid constituency name (but no MP), requesting XML
    Given I call the search API searching for "Glenrothes" and requesting "xml"
    Then I should see "<constituency>"
    And I should see "<constituency-name>Glenrothes</constituency-name>"
    And I should see "<member-name>No sitting member</member-name>"
    And I should see "<member-party></member-party>"
    And I should see "<member-biography-url></member-biography-url>"
    And I should see "<member-website></member-website>"
    And I should see "/constituencies/glenrothes.xml</uri>"

  Scenario: Call search API with partial member name which will return more than 1 result line, requesting XML
    Given I call the search API searching for "Frank" and requesting "xml"
    Then I should see "<results>"
    And I should see "<constituency-name>Aberdeen North</constituency-name>"
    And I should see "<member-name>Frank Doran</member-name>"
    And I should see "<constituency-name>Motherwell and Wishaw</constituency-name>"
    And I should see "<member-name>Mr Frank Roy</member-name>"
    And I should see "/constituencies/motherwell-and-wishaw.xml</uri>"
    And I should see "/constituencies/aberdeen-north.xml</uri>"

  Scenario: Call search API with an invalid search term, requesting XML
    Given I call the search API searching for "invalid" and requesting "xml"
    Then I should see "<error>"

  Scenario: Call search API to return a single record where the constituency name contains a "&" character, requesting XML
    Given I call the search API searching for "Newry" and requesting "xml"
    Then I should see "<constituency>"
    And I should see "<constituency-name>Newry &amp; Armagh</constituency-name>"

  Scenario: Call search API with postcode district, requesting XML
    Given I call the search API searching for "BT35" and requesting "xml"
    Then I should see "<results>"
    And I should see "<constituency-matches>"
    And I should see "<constituency-name>Upper Bann</constituency-name>"
    And I should see "<constituency-name>Newry &amp; Armagh</constituency-name>"
    And I should see "/constituencies/upper-bann.xml</uri>"
    And I should see "/constituencies/newry-armagh.xml</uri>"
