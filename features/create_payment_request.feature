Feature: Request a payment
  In order to pay someone
  As a seller with with application
  I want to create verified payment requests

  @create_payment_request
  Scenario: Payment request
    When a payment is requested to: "someone@gmail.com", amount: "5000.00", currency: "THB", id: 347752
    Then a payment request should exist with to: "someone@gmail.com", verified_at: nil
    And the payment request should have the following parameters: to: "someone@gmail.com", amount: "5000.00", currency: "THB", id: "347752"
    And a verification request should be made to the requester application with to: "someone@gmail.com", amount: "5000.00", currency: "THB", id: "347752"

