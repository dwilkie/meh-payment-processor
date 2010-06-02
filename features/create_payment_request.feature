Feature: Create Payment Request
  In order to keep a track of payment requests
  As a seller payment application
  I want to be able to see existing payment requests

  Scenario: Save payment request
    When a payment is requested to: "someone@gmail.com", amount: "5000.00", currency: "THB", something_else: "This could be anything"
    Then a payment request should exist with to: "someone@gmail.com"
    And the payment request should have the following parameters: to: "someone@gmail.com", amount: "5000.00", currency: "THB", something_else: "This could be anything"
    
  Scenario: Send the parameters back to the main application for verification
    Given a payment request exists to: "someone@gmail.com", amount: "5000.00", currency: "THB", something_else: "This could be anything"

