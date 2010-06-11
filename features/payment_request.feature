Feature: Payment Request
  In order to pay people
  As an owner of this application
  I want to allow verified payment requests to be made to my application

  Scenario: A payment request is received from the configured external application and I have not configured any payees in my app (default)
    Given I have not configured any payees

    When the configured external application makes a payment request with: "{'external_id' => 347752, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'someone@gmail.com' }, 'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'someone@gmail.com'} }"

    Then a payment_request should exist with external_id: 347752
    And a HEAD request should have been made to the external application for the payment request: 347752, with the query string containing: "{'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'someone@gmail.com'}, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'someone@gmail.com' } }"

    Given the response was "200 OK"

    Then a POST request should have been made to my paypal account containing: amount: "5000.00", currency: "THB", receiver: "someone@gmail.com"

    And the payment request should be completed
    And a PUT request should have been made to the external application for the payment request: 347752, containing: the paypal response

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay the configured payee
    Given a payee exists with email: "johnny@gmail.com"

    When the configured external application makes a payment request with: "{'external_id' => 347752, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'johnny@gmail.com' }, 'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'johnny@gmail.com'} }"

    Then a HEAD request should have been made to the external application for the payment request: 347752, with the query string containing: "{'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'johnny@gmail.com'}, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'johnny@gmail.com' } }"

    Given the response was "200 OK"

    Then a POST request should have been made to my paypal account containing: amount: "5000.00", currency: "THB", receiver: "johnny@gmail.com"
    And the payment request should be completed
    And a PUT request should have been made to the external application for the payment request: 347752, containing: the paypal response

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay a different payee
    Given a payee exists with email: "johnny@gmail.com"

    When the configured external application makes a payment request with: "{'external_id' => 347752, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'johnny2@gmail.com' }, 'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'johnny2@gmail.com'} }"

    Then a HEAD request should have been made to the external application for the payment request: 347752, with the query string containing: "{'payment' => { 'amount' => '5000.00', 'currency' => 'THB', 'receiver' => 'johnny2@gmail.com'}, 'payee' => { 'amount' => '5000.00', 'currency' => 'THB', 'email' => 'johnny2@gmail.com' } }"

    Given the response was "200 OK"

    Then a POST request should not have been made to my paypal account
    And the payment request should be unauthorized
    And a PUT request should have been made to the external application for the payment request: 347752, containing: "{'payee_not_found' => true}"

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay the configured payee but for an amount greater than the maximum allowed for this payee
    Given a payee exists with email: "johnny@gmail.com", maximum_amount: "500.00", currency: "THB"

    When the configured external application makes a payment request with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.01', 'currency' => 'THB', 'email' => 'johnny@gmail.com' }, 'payment' => { 'amount' => '500.01', 'currency' => 'THB', 'receiver' => 'johnny@gmail.com'} }"

    Then a HEAD request should have been made to the external application for the payment request: 347752, with the query string containing: "{'payment' => { 'amount' => '500.01', 'currency' => 'THB', 'receiver' => 'johnny@gmail.com'}, 'payee' => { 'amount' => '500.01', 'currency' => 'THB', 'email' => 'johnny@gmail.com' } }"

    Given the response was "200 OK"

    Then a POST request should not have been made to my paypal account
    And the payment request should be unauthorized
    And a PUT request should have been made to the external application for the payment request: 347752, containing: "{'payee_maximum_amount_exceeded' => true}"

  Scenario: I have configured a payee in my app and a payment request is received from the configured external app to pay the configured payee but for a currency that is different than the one set for the configured payee
    Given a payee exists with email: "johnny@gmail.com", maximum_amount: "500.00", currency: "THB"

    When the configured external application makes a payment request with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'johnny@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'johnny@gmail.com'} }"

    Then a HEAD request should have been made to the external application for the payment request: 347752, with the query string containing: "{'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'johnny@gmail.com'}, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'johnny@gmail.com' } }"

    Given the response was "200 OK"

    Then a POST request should not have been made to my paypal account
    And the payment request should be unauthorized

    And a PUT request should have been made to the external application for the payment request: 347752, containing: "{'payee_currency_invalid' => true}"

  Scenario: A payment request is received with a duplicate external_id
    When a payment request is received with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'johnny@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'johnny@gmail.com'} }"

    And another payment request is received with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'johnny@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'johnny@gmail.com'} }"

    Then 1 payment request should exist
    And no outgoing requests should be made
    And the payment request should not be verified

  Scenario: A payment request is received but it was not from the configured external application
    When a payment request is received with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'attacker@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'attacker@gmail.com'} }"

    Then a payment_request should be created with external_id: 347752
    And a HEAD request should have been made to the external application for the payment request: 347752, with the query string containing: "{'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'attacker@gmail.com'}, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'attacker@gmail.com' } }"

    Given the response was "404 Not Found"

    Then the payment request should not be verified
    And the payment request should be unauthorized

  Scenario: A CSRF attack triggers the process payment request task for a payment request that was already completed
    Given a completed payment request exists with id: 12345
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that was already sent for processing but has not yet been completed
    Given a processing payment request exists with id: 12345
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that is not yet verified (i.e. the payment request has been created but the external app hasn't got back to us yet)
    Given a payment request exists with id: 12345
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that is internally unauthorized (i.e. I set up payee restrictions internally that did not accomodate the request)
    Given an internally unauthorized payment request exists with id: 12345
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

  Scenario: A CSRF attack triggers the process payment request task for a payment request that is externally unauthorized (i.e. the payment request was not made by the configured externaly application)
    Given an externally unauthorized payment request exists with id: 12345
    And I am logged in

    When I am CSRF attacked to trigger the process payment request task for the payment request: 12345

    Then a POST request should not have been made to my paypal account

