Feature: Incoming Payment Request
  In order to pay people
  As an owner of this application
  I want to allow verified payment requests to be made to my application

  Scenario: A payment request is received from the configured external application
    Given I have configured my app correctly for paypal
    When the configured external application makes a payment request with external_id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment_request should exist with external_id: 347752
    And a HEAD request should have been made to the external application for the payment request: 347752 returning status "200 OK" with amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    And the payment request should be verified
    And a POST request should have been made to my paypal account returning status "200 OK" containing the payment details
    And a PUT request should have been made to the external application for the payment request: 347752 returning status "200 OK" containing the paypal response

  Scenario: A payment request is received but it was not from the configured external application
    When a payment request is received with external_id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment_request should be created with external_id: 347752
    But a HEAD request should have been made to the external application for the payment request: 347752 returning status "404 Not Found" with amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    And the payment request should not be verified
