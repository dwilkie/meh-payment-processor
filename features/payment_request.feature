Feature: Payment Request
  In order to pay people
  As an owner of this application
  I want to allow verified payment requests to be made to my application

  @current
  Scenario: A payment request is received from the configured external application and I have not configured any payees in my app (default)
    Given I have not configured any payees

    When the configured external application makes a payment request with: "{'external_id' => 347752, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'someone@gmail.com' }, 'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'someone@gmail.com'} }"

    Then a payment_request should exist with external_id: 347752
    And a HEAD request should have been made to the external application for the payment request: 347752 with the query string containing: "{'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'someone@gmail.com'}, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'someone@gmail.com' } }"

    Given the response was "200 OK"

    Then a POST request should have been made to my paypal account containing: amount: "5000.00", currency: "THB", receiver: "someone@gmail.com"

    And the payment request should be completed
    And a PUT request should have been made to the external application for the payment request: 347752, containing: the paypal response

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay the configured payee
    Given a payee exists with email: "johnny@gmail.com"

    When the configured external application makes a payment request with external_id: 3434121, amount: "5000.00", currency: "THB", payee: "johnny@gmail.com"

    Then a HEAD request should have been made to the external application for the payment request: 3434121 with the query string containing: amount: "5000.00", currency: "THB", payee: "johnny@gmail.com"

    Given the response was "200 OK"

    And a POST request should have been made to my paypal account containing: amount: "5000.00", currency: "THB", payee: "johnny@gmail.com"
    And the payment request should be completed
    And a PUT request should have been made to the external application for the payment request: 3434121 containing: the paypal response

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay a different payee
    Given a payee exists with email: "johnny@gmail.com"

    When the configured external application makes a payment request with external_id: 3434121, amount: "5000.00", currency: "THB", to: "mary@gmail.com"

    Then a HEAD request should have been made to the external application for the payment request: 3434121 returning status "200 OK" with amount: "5000.00", currency: "THB", to: "mary@gmail.com"
    But a POST request should not have been made to my paypal account
    And the payment request should be unauthorized
    And a PUT request should have been made to the external application for the payment request: 3434121 returning status "200 OK" containing errors payee_not_found: true

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay the configured payee but for an amount greater than the maximum allowed for this payee
    Given a payee exists with email: "johnny@gmail.com", maximum_amount: "500.00", currency: "THB"

    When the configured external application makes a payment request with external_id: 3434121, amount: "500.01", currency: "THB", to: "johnny@gmail.com"

    Then a HEAD request should have been made to the external application for the payment request: 3434121 returning status "200 OK" with amount: "500.01", currency: "THB", to: "johnny@gmail.com"
    But a POST request should not have been made to my paypal account
    And the payment request should be unauthorized
    And a PUT request should have been made to the external application for the payment request: 3434121 returning status "200 OK" containing errors payee_maximum_amount_exceeded: true

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay the configured payee but for a currency that is different than the one set for the configured payee
    Given a payee exists with email: "johnny@gmail.com", maximum_amount: "500.00", currency: "THB"

    When the configured external application makes a payment request with external_id: 3434121, amount: "300.00", currency: "USD", to: "johnny@gmail.com"

    Then a HEAD request should have been made to the external application for the payment request: 3434121 returning status "200 OK" with amount: "300.00", currency: "USD", to: "johnny@gmail.com"
    But a POST request should not have been made to my paypal account
    And the payment request should be unauthorized
    And a PUT request should have been made to the external application for the payment request: 3434121 returning status "200 OK" containing errors payee_invalid_currency: true

  Scenario: A payment request is received with a duplicate external_id
    When a payment request is received with external_id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    And another payment request is received with external_id: 347752

    Then 1 payment request should exist
    And no outgoing requests should be made
    And the payment request should not be verified

  Scenario: A payment request is received but it was not from the configured external application
    When a payment request is received with external_id: 347752, amount: "5000.00", currency: "THB", to: "someone@gmail.com"

    Then a payment_request should be created with external_id: 347752
    But a HEAD request should have been made to the external application for the payment request: 347752 returning status "404 Not Found" with amount: "5000.00", currency: "THB", to: "someone@gmail.com"
    And the payment request should not be verified
    And the payment request should be unauthorized

  Scenario: A CSRF attack triggers the process payment request task for a payment request that was already completed
    Given a completed payment request exists with id: 12345, external_id: 23421
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that was already sent for processing but has not yet been completed
    Given a processing payment request exists with id: 12345, external_id: 23421
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that is not verified
    Given a payment request exists with id: 12345, external_id: 23421, email: "attacker@somewhere.com", amount: "1000.00", currency: "USD"
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that is internally unauthorized
    Given a verified payment request exists with id: 12345, external_id: 23421, email: "attacker@somewhere.com", amount: "1000.00", currency: "USD", status: "internally_unauthorized"
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

