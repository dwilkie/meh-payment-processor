Feature: Payment Request Notification verification
  In order to prevent unauthorized payment notifications made to the remote application from having an affect on me
  As an owner of this application
  I want to verify that a payment notification was made by this application

  Scenario: Payment notification verification is made with correct parameters
    Given a completed payment request exists with id: 2423, payment_response: "payment_response[someresponse]=response"

    When a payment notification verification request is received for 2423 with: "{'payment_response'=>{'someresponse'=>'response'}}"

    Then the response should be 200

  Scenario: Payment notification verification is made with correct parameters but for a payment request where the notification has not yet been sent
    Given a payment request exists with id: 2423

    When a payment notification verification request is received for 2423

    Then the response should be 404

  Scenario: Payment request verification is made for unknown resource
    Given a completed payment request exists with id: 2423

    When a payment notification verification request is received for 2422

    Then the response should be 404

  Scenario: Payment request verification is made for correct resource with incorrect parameters
    Given a completed payment request exists with id: 2423, payment_response: "payment_response[someresponse]=response"

    When a payment notification verification request is received for 2423 with: "{'payment_response'=>{'someresponse'=>'respons'}}"

    Then the response should be 404

