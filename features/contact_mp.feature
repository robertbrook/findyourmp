Feature: Contact MP
  In order to contact my MP
  as a constituent
  want to send message via Web form

  Scenario: Follow send a message link
    Given my MP is contactable via email
    And I am on a Postcode page
    When I follow "Send a message to Frank Doran"
    Then I should see "Send email"

