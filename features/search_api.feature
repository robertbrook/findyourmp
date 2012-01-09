Feature: Search API
  In order to search using the API
  as a constituent
  I want to get data via the search API

  Scenario: Call search API with valid postcode, requesting XML
    Given I call the search API searching for "AB101AA" and requesting "xml"
    Then I should see xml "<results>"
    Then I should see xml "<constituencies>"
    Then I should see xml "  <constituency>"
    Then I should see xml "    <constituency-name>Aberdeen North</constituency-name>"
    Then I should see xml "    <member-name>Frank Doran</member-name>"
    Then I should see xml "    <member-party></member-party>"
    Then I should see xml "    <member-biography-url></member-biography-url>"
    Then I should see xml "    <member-website></member-website>"
    Then I should see xml "    <uri>http://www.example.com/constituencies/aberdeen-north.xml</uri>"

  Scenario: Call search API with valid postcode, requesting plain text
    Given I call the search API searching for "AB101AA" and requesting "text"
    And I should see "constituency_name: Aberdeen North"
    And I should see "member_name: Frank Doran"

  Scenario: Call search API with valid postcode, requesting JSON
    Given I call the search API searching for "AB101AA" and requesting "json"
    Then I should see json {"results": { "constituencies": [{"constituency_name": "Aberdeen North", "member_name": "Frank Doran", "member_party": "", "member_biography_url": "", "member_website": "", "uri": "http://www.example.com/constituencies/aberdeen-north.json" } ], "members": [] }}

  Scenario: Call search API with valid postcode, requesting CSV
    Given I call the search API searching for "AB101AA" and requesting "csv"
    Then I should see "constituency_name,member_name,member_party,member_biography_url,member_website"
    And I should see csv "Aberdeen North","Frank Doran","","","","http://www.example.com/constituencies/aberdeen-north.csv"

  Scenario: Call search API with valid constituency name, requesting XML
    Given I call the search API searching for "Aberdeen South" and requesting "xml"
    Then I should see xml "<constituency>"
    And I should see xml "<constituency-name>Aberdeen South</constituency-name>"
    And I should see xml "<member-name>Miss Anne Begg</member-name>"
    And I should see xml "<member-party></member-party>"
    And I should see xml "<member-biography-url></member-biography-url>"
    And I should see xml "<member-website></member-website>"
    And I should see xml "/constituencies/aberdeen-south.xml</uri>"

  Scenario: Call search API with valid constituency name, requesting JSON
    Given I call the search API searching for "Aberdeen South" and requesting "json"
    Then I should see json { "constituencies": [
    And I should see json "constituency_name": "Aberdeen South"
    And I should see json "member_name": "Miss Anne Begg"
    And I should see json "member_party": ""
    And I should see json "member_biography_url": ""
    And I should see json "member_website": ""
    And I should see json "uri":
    And I should see json /constituencies/aberdeen-south.json

  Scenario: Call search API with valid constituency name (but no MP), requesting XML
    Given I call the search API searching for "Glenrothes" and requesting "xml"
    Then I should see xml "<constituency>"
    And I should see xml "<constituency-name>Glenrothes</constituency-name>"
    And I should see xml "<member-name>No sitting member</member-name>"
    And I should see xml "<member-party></member-party>"
    And I should see xml "<member-biography-url></member-biography-url>"
    And I should see xml "<member-website></member-website>"
    And I should see xml "/constituencies/glenrothes.xml</uri>"

  Scenario: Call search API with partial member name which will return more than 1 result line, requesting XML
    Given I call the search API searching for "Frank" and requesting "xml"
    Then I should see xml "<results>"
    And I should see xml "<constituency-name>Aberdeen North</constituency-name>"
    And I should see xml "<member-name>Frank Doran</member-name>"
    And I should see xml "<constituency-name>Motherwell and Wishaw</constituency-name>"
    And I should see xml "<member-name>Mr Frank Roy</member-name>"
    And I should see xml "/constituencies/motherwell-and-wishaw.xml</uri>"
    And I should see xml "/constituencies/aberdeen-north.xml</uri>"

  Scenario: Call search API with an invalid search term, requesting XML
    Given I call the search API searching for "invalid" and requesting "xml"
    Then I should see xml "<constituencies></constituencies>"

  Scenario: Call search API to return a single record where the constituency name contains a "&" character, requesting XML
    Given I call the search API searching for "Newry" and requesting "xml"
    Then I should see xml "<constituency>"
    And I should see xml "<constituency-name>Newry &amp; Armagh</constituency-name>"

  Scenario: Call search API with postcode district, requesting XML
    Given I call the search API searching for "BT35" and requesting "xml"
    Then I should see xml "<results>"
    And I should see xml "<constituency>"
    And I should see xml "<constituency-name>Upper Bann</constituency-name>"
    And I should see xml "<constituency-name>Newry &amp; Armagh</constituency-name>"
    And I should see xml "/constituencies/upper-bann.xml</uri>"
    And I should see xml "/constituencies/newry-armagh.xml</uri>"
