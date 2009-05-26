Feature: Postcodes API
  In order to retrieve postcode data using the API
  as a constituent
  I want to get data via the postcodes API

  Scenario: Call postcodes API with valid postcode, requesting XML
    Given I call the postcodes API with "AB101AA", requesting "xml"
    Then I should see xml "<results>"
    Then I should see xml "<constituencies>"
    Then I should see xml "  <constituency>"
    Then I should see xml "    <constituency-name>Aberdeen North</constituency-name>"
    Then I should see xml "    <member-name>Frank Doran</member-name>"
    Then I should see xml "    <member-party></member-party>"
    Then I should see xml "    <member-biography-url></member-biography-url>"
    Then I should see xml "    <member-website></member-website>"
    Then I should see xml "    <uri>http://www.example.com/constituencies/aberdeen-north.xml</uri>"

  Scenario: Call postcodes API with valid postcode district, requesting XML
    Given I call the postcodes API with district "BT35", requesting "xml"
    Then I should see xml "<results>"
    And I should see xml "<constituencies>"
    And I should see xml "<constituency-name>Upper Bann</constituency-name>"
    And I should see xml "<constituency-name>Newry &amp; Armagh</constituency-name>"
    And I should see xml "/constituencies/upper-bann.xml</uri>"
    And I should see xml "/constituencies/newry-armagh.xml</uri>"