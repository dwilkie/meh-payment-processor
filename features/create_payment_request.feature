Feature: Request a payment
  In order to pay someone
  As a seller with with application
  I want to create verified payment requests

  @create_payment_request
  Scenario: A payment request is received
    When a payment request is received with id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment request should be created with to: "someone@gmail.com"
    But the payment request should not be verified
    And a verification request should be made to the configured external application with id: "347752", amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    
  Scenario: The payment request was made by the configured requesting application
    When the configured external application makes a payment request with id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    Then a payment request should exist with to: "someone@gmail.com"
    And the payment request should be verified

