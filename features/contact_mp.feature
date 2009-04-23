Feature: Contact MP
  In order to contact my MP
  as a constituent
  want to send message via Web form

  Scenario: Follow the "send a message" link from postcode page
    Given my MP is contactable via email
    And I am on my Postcode page
    When I follow "Email Frank Doran"
    Then I should see Message Form

  Scenario: Follow the "send a message" link from constituency page
    Given my MP is contactable via email
    And I am on my Constituency page
    When I follow "Email Frank Doran"
    Then I should see Message Form

    Scenario: Preview message with compulsory field missing and see generic warning
    Given I am on a new Message page
    When I preview message without "Your email address"
    And I should see "1 error prohibited this message from being previewed"
    And I should see "Preview your message" button

  Scenario Outline: Preview message with compulsory field missing and see detailed warning
    Given I am on a new Message page
    When I preview message without "<field_missing>"
    Then I should see "<warning_message>"

  Examples:
    | field_missing      | warning_message                 |
    | Your email address | Please enter your email address |
    | Your full name     | Please enter your full name     |
    | Your subject       | Please enter your subject       |
    | Your message       | Please enter your message       |

  Scenario: Preview message with invalid email and see detailed warning
    Given I am on a new Message page
    When I preview message with an invalid sender email
    Then I should see "1 error prohibited this message from being previewed"
    And I should see "Please enter a valid email address"

  Scenario: Preview message with invalid email and see detailed warning
    Given I am on a new Message page
    When I preview message with a parliament.uk sender email
    Then I should see "1 error prohibited this message from being previewed"
    And I should see "Please enter a non parliament.uk email address"

  Scenario: Preview message with invalid postcode and see detailed warning
    Given I am on a new Message page
    When I preview message with an invalid postcode
    Then I should see "1 error prohibited this message from being previewed"
    And I should see "Please enter a valid postcode"

  Scenario: Preview message
    Given I am on a new Message page
    When I preview message
    Then I should see "Re-edit your message" button
    And I should see "Send message" button

  Scenario: Re-edit message
    Given I am on a preview Message page
    When I re-edit message
    Then I should see "Preview your message" button
    When I preview message
    Then I should see "Re-edit your message" button
    And I should see "Send message" button

  Scenario: Send message
    Given I am on a preview Message page
    When I send message
    Then I should see "Your message has been sent."

  Scenario: My MP is not contactable via email
    Given I am on the Front page
    And the MP in constituency "Motherwell and Wishaw" is not contactable via email
    When I search for "Motherwell and Wishaw"
    Then I should see "Mr Frank Roy"
    And I should see "Mr Frank Roy cannot be contacted by email"
    And I should see "from this website."
