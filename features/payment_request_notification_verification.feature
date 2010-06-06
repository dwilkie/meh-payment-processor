Feature: Payment Request Notification verification
  In order to prevent unauthorized payment notifications made to the external application from having an affect on me
  As an owner of this application
  I want to verify that a payment notification was made by this application

  Scenario: Payment notification verification is made with correct parameters
    Given a completed payment request exists with id: 2423, external_id: 76543, email: "someone@example.com", amount: "300.00", currency: "THB"

    When a payment notification verification request is received for 2423 with external_id: 76543, email: "someone@example.com", amount: "300.00", currency: "THB"
    
    Then the response should be 200
    
  Scenario: Payment notification verification is made with correct parameters but for a payment request which has is not completed
    Given a payment request exists with id: 2423, external_id: 76543, email: "someone@example.com", amount: "300.00", currency: "THB"
    
    When a payment notification verification request is received for 2423 with external_id: 76543, email: "someone@example.com", amount: "300.00", currency: "THB"
    
    Then the response should be 404
      
  Scenario: Payment request verification is made for unknown resource
    Given a completed payment request exists with id: 2423, external_id: 76543, email: "someone@example.com", amount: "300.00", currency: "THB"

    When a payment notification verification request is received for 2422
    
    Then the response should be 404

  Scenario Outline: Payment request verification is made for correct resource with incorrect parameters
    Given a completed payment request exists with id: 2423, external_id: 76543, email: "someone@example.com", amount: "300.00", currency: "THB"

    When a payment notification verification request is received for 2423 with <parameters>

    Then the response should be 404
    
    Examples:
      | parameters                                                       |
      | email: "someone1@example.com", amount: "300.00", currency: "THB" |
      | email: "someone@example.com", amount: "300.01", currency: "THB"  |
      | email: "someone@example.com", amount: "300.00", currency: "USD"  |

