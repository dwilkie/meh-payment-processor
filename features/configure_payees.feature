Feature: Configure Payees
  In order to increase security
  As an owner of this application
  I want to be able to configure who I pay and set limits on how much I pay them
  
  Scenario: Add Payee
    Given I am logged in
    And I go to the payees page
    When I follow "Add New"
    Then I should be on the new payee page

