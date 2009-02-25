Feature: Search API
  In order to retrieve postcode data using the API
  as a constituent
  I want to get data via the postcodes API

  Scenario: Call postcodes API with valid postcode, requesting XML
    Given I call the postcodes API with "AB101AA", requesting "xml"
    Then I should see "<postcode>"
    And I should see "<code>AB10 1AA</code>"
    And I should see "<constituency-name>Aberdeen North</constituency-name>"
    And I should see "<member>Frank Doran</member>"

  Scenario: Call postcodes API with valid postcode district, requesting XML
    Given I call the postcodes API with district "BT35", requesting "xml"
    Then I should see "<results>"
    And I should see "<constituency-matches>"
    And I should see "<constituency-name>Upper Bann</constituency-name>"
    And I should see "<constituency-name>Newry &amp; Armagh</constituency-name>"