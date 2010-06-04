Feature: Incoming Payment Request
  In order to pay people
  As an owner of this application
  I want to allow verified payment requests to be made to my application

  Scenario: A payment request is received but it was not from the configured external application
    When a payment request is received with external_id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment_request should be created with external_id: 347752
    And a verification request should be made to the configured external application for 347752 with amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    But the response should be status "404 Not Found"
    And the payment request should not be verified

  Scenario: A payment request is received from the configured external application
    When the configured external application makes a payment request with external_id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment_request should exist with external_id: 347752
    And a verification request should be made to the configured external application for 347752 with amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    And the response should be status "200 OK"
    And the payment request should be verified


