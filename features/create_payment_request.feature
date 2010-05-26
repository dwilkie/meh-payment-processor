Feature: Create Payment Request
  In order to keep a track of my payments
  As a seller
  I want to be able to see existing payment requests

  Scenario: Save payment request
    When I request a payment
    Then there should be a payment request
