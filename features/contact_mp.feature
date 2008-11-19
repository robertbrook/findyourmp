Feature: Contact MP
  In order to contact my MP
  as a constituent
  want to send message via Web form

  Scenario: Follow the "send a message" link
    Given my MP is contactable via email
    And I am on my Postcode page
    When I follow "Send a message to Frank Doran"
    Then I should see "Your email address"
    And I should see "Your full name"
    And I should see "Your postal address"
    And I should see "Your postcode"
    And I should see "Your subject"
    And I should see "Your message"
    And I should see "Send email"

  Scenario: Send message with complusory field missing
    Given I am on a new Message page
    When I send message without "Your email address"
    Then I should see "Sender email can't be blank"

  More Examples:
    | field_missing      | warning_message         |
    | Your full name     | Sender can't be blank   |
    | Your subject       | Subject can't be blank  |
    | Your message       | Message can't be blank  |

