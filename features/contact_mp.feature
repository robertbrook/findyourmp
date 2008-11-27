Feature: Contact MP
  In order to contact my MP
  as a constituent
  want to send message via Web form

  Scenario: Follow the "send a message" link from postcode page
    Given my MP is contactable via email
    And I am on my Postcode page
    When I follow "Send a message to Frank Doran"
    Then I should see Message Form

  Scenario: Follow the "send a message" link from constituency page
    Given my MP is contactable via email
    And I am on my Constituency page
    When I follow "Send a message to Frank Doran"
    Then I should see Message Form

  Scenario: Preview message with compulsory field missing
    Given I am on a new Message page
    When I preview message without "Your email address"
    Then I should see "Sender email can't be blank"
    And I should see "Preview your message"

  More Examples:
    | field_missing      | warning_message         | button label         |
    | Your full name     | Sender can't be blank   | Preview your message |
    | Your subject       | Subject can't be blank  | Preview your message |
    | Your message       | Message can't be blank  | Preview your message |

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

