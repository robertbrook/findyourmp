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
    And I should see "Preview your message"

  Scenario: Preview message with complusory field missing
    Given I am on a new Message page
    When I preview message without "Your email address"
    Then I should see "Sender email can't be blank"
    And I should see "Preview your message"

  More Examples:
    | field_missing      | warning_message         |
    | Your full name     | Sender can't be blank   |
    | Your subject       | Subject can't be blank  |
    | Your message       | Message can't be blank  |

  Scenario: Preview message
    Given I am on a new Message page
    When I preview message
    Then I should see "Re-edit your message"
    And I should see "Send message"

  Scenario: Re-edit message
    Given I am on a preview Message page
    When I re-edit message
    Then I should see "Preview your message"
    When I preview message
    Then I should see "Re-edit your message"
    And I should see "Send message"

  Scenario: Send message
    Given I am on a preview Message page
    When I send message
    Then I should see "Your message has been sent."

