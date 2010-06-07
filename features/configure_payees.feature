Feature: Configure Payees
  In order to increase security
  As an owner of this application
  I want to be able to configure who I pay and set limits on how much I pay them
  
  Scenario: Navigate to new payee page from the homepage
    Given I am on the homepage
    And I am logged in

    When I follow "Configure Payees"
    Then I should be on the payees page
    
    When I follow "Add New"
    Then I should be on the new payee page
    
  Scenario: Create a new payee supplying correct data
    Given I am on the new payee page
    
    When I fill in the following:
    | Email          | someone@example.com |
    | Name           | John                |
    | Maximum Amount | 500                 |
    And I select "THB" from "Currency"
    And I press "Add"
    
    Then I should be on the payees page
    And I should see "John"
    And I should see "someone@example.com"
    And I should see "500.00 THB"
    
  Scenario: Try and create a payee with no email address
    Given I am on the new payee page
    
    When I press "Add Payee"

    Then I should see "Email must not be blank"

  Scenario: Try and create a payee with an invalid email address
    Given I am on the new payee page
    
    When I fill in "Email" with "meh"
    And I press "Add Payee"
    
    Then I should see "Email has an invalid format"
    
  Scenario: Navigate to edit payee page from the homepage
    Given a payee exists with email: "john@example.com"
    And I am on the homepage
    
    When I follow "Configure Payees"
    And I follow "edit" within "#li"
    
    
    
   
