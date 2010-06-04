Feature: Request a payment
  In order to pay people
  As an owner of this application
  I want allow verified payment requests to be made

  Scenario: A payment request is received
    When a payment request is received with id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment_request should be created with to: "someone@gmail.com"
    And a verification request should be made to the configured external application for 347752 with id: "347752", amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    But the payment request should not be verified

  Scenario: A payment request is received from the configured external application
    When the configured external application makes a payment request with id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment_request should exist with to: "someone@gmail.com"
    And a verification request should be made to the configured external application for 347752 with id: "347752", amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    And the response should be status "200 OK"
    And the payment request should be verified

