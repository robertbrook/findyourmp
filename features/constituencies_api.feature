Feature: Constituencies API
  In order to retrieve constituency data using the API
  as a constituent
  I want to get data via the constituencies API

  Scenario: Call constituencies API with valid ONS id, requesting XML
    Given I call the constituencies API with an ONS id of "801", requesting "xml"
    Then I should see xml "<constituency>"
    And I should see xml "<constituency-name>Aberdeen North</constituency-name>"
    And I should see xml "<member-name>Frank Doran</member-name>"

  Scenario: Call constituencies API with a valid member name, requesting XML
    Given I call the constituencies API with a member name of "Miss Anne Begg", requesting "xml"
    Then I should see xml "<constituency>"
    And I should see xml "<constituency-name>Aberdeen South</constituency-name>"
    And I should see xml "<member-name>Miss Anne Begg</member-name>"

  Scenario: Call constituencies API with valid constituency name, requesting XML
    Given I call the constituencies API with a constituency name of "Glenrothes", requesting "xml"
    Then I should see xml "<constituency>"
    And I should see xml "<constituency-name>Glenrothes</constituency-name>"
    And I should see xml "<member-name>No sitting member</member-name>"

  Scenario: Call constituencies API without a valid parameter
    Given I call the constituencies API with no parameters, requesting "xml"
    Then I should see xml "Sorry: the API did not recognise this parameter"
