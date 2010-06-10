Feature: Payment Request Notification verification
  In order to prevent unauthorized payment notifications made to the external application from having an affect on me
  As an owner of this application
  I want to verify that a payment notification was made by this application

  Scenario: Payment notification verification is made with correct parameters
    Given a completed payment request exists with id: 2423, "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"

    When a payment notification verification request is received for 2423 with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"

    Then the response should be 200

  Scenario: Payment notification verification is made with correct parameters but for a payment request which has is not completed
    Given a payment request exists with id: 2423, "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"

    When a payment notification verification request is received for 2423 with: "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"

    Then the response should be 404

  Scenario: Payment request verification is made for unknown resource
    Given a completed payment request exists with id: 2423, "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"

    When a payment notification verification request is received for 2422

    Then the response should be 404

  Scenario Outline: Payment request verification is made for correct resource with incorrect parameters
    Given a completed payment request exists with id: 2423, "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"

    When a payment notification verification request is received for 2423 with: <parameters>

    Then the response should be 404

    Examples:
      | parameters                                                       |
      |  "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'USD', 'email' => 'supplier1@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'USD', 'receiver' => 'supplier1@gmail.com'} }"                        |
      | "{'external_id' => 347752, 'payee' => { 'amount' => '500.01', 'currency' => 'USD', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.01', 'currency' => 'USD', 'receiver' => 'supplier@gmail.com'} }"                            |
      | "{'external_id' => 347752, 'payee' => { 'amount' => '500.00', 'currency' => 'THB', 'email' => 'supplier@gmail.com' }, 'payment' => { 'amount' => '500.00', 'currency' => 'THB', 'receiver' => 'supplier@gmail.com'} }"                            |

