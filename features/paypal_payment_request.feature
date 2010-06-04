Feature: Paypal Payment Request
  In order to pay people
  As an owner of this application
  I want to forward payment requests to my linked paypal account for verified requests
  
  Background:
    Given a payment request exists with to: "someone@gmail.com"
    And the payment request has the following parameters: id: "347752", amount: "5000.00", currency: "THB", to: "someone@gmail.com"
  
  Scenario:
    When an incoming payment request is verified
    Then a payment request should be made to my configured paypal account for 347752 with 
