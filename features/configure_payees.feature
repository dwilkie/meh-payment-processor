Feature: Configure Payees
  In order to increase security
  As an owner of this application
  I want to be able to configure who I pay and set limits on how much I pay them

  Scenario: Navigate to new payee page from the homepage
    Given I am on the homepage
    And I am logged in

    When I follow "Add new"

    Then I should be on the new payee page
    And I should see "Add Payee"
    And the "payee_submit" field should contain "Add"

  Scenario: Create a new payee supplying correct data
    Given I am on the new payee page

    When I fill in the following:
    | Email          | someone@example.com |
    | Name           | John                |
    | Maximum amount | 500                 |
    And I select "THB" from "Currency"
    And I press "Add"

    Then I should be on the payees page
    And I should see "John"
    And I should see "someone@example.com"
    And I should see "500.00 THB"

  Scenario: Cancel adding a payee
    Given I am on the new payee page

    When I fill in "Email" with "johnny@gmail.com"
    And I follow "Cancel"

    Then I should be on the payees page
    And I should not see "johnny@gmail.com"

  Scenario: Try and create a payee with no email address
    Given I am on the new payee page

    When I press "Add"

    Then I should see "Email must not be blank"

  Scenario: Try and create a payee with an invalid email address
    Given I am on the new payee page

    When I fill in "Email" with "meh"
    And I press "Add"

    Then I should see "Email has an invalid format"

  Scenario: Try and create a duplicate payee
    Given I am on the new payee page
    And a payee exists with email: "john@example.com"

    When I fill in "Email" with "john@example.com"
    And I press "Add"

    Then I should see "Email is already taken"

  Scenario: Forget to select a currency when specifying a maximum amount
    Given I am on the new payee page

    When I fill in "Email" with "john@example.com"
    And I fill in "Maximum amount" with "500"
    And I press "Add"

    Then I should see "Currency must not be blank"

  Scenario: Navigate to edit page from the homepage
    Given a payee exists with email: "john@example.com", name: "Johnny", maximum_amount: "500", currency: "THB"
    And I am on the homepage
    When I follow "Edit" for that payee

    Then I should be on the edit page for that payee
    And I should see "Editing Payee: Johnny"
    And the "payee_name" field should contain "Johnny"
    And the "payee_email" field should contain "john@example.com"
    And the "payee_maximum_amount" field should contain "500.00"
    And the "payee_currency" field should contain "THB"
    And the "payee_submit" field should contain "Update"

  Scenario: Update a payee
    Given a payee exists with email: "john@example.com", name: "Johnny", maximum_amount: "500", currency: "THB"
    And I am on the edit page for that payee

    When I fill in "Maximum amount" with "1000"

    And I press "Update"
    Then I should be on the payees page
    And I should see "Johnny"
    And I should see "john@example.com"
    And I should see "1,000.00 THB"

  Scenario: Cancel updating a payee
    Given a payee exists with email: "john@example.com"
    And I am on the edit page for that payee

    When I fill in "Email" with "johnny2@gmail.com"
    And I follow "Cancel"

    Then I should be on the payees page
    And I should see "john@example.com"
    And I should not see "johnny2@gmail.com"

  Scenario: Try to update a payee with invalid values
    Given a payee exists with email: "john@example.com", name: "Johnny", maximum_amount: "500", currency: "THB"
    And I am on the edit page for that payee

    When I fill in "Email" with ""
    And I select "" from "Currency"
    And I press "Update"

    Then I should see "Email must not be blank"
    And I should see "Currency must not be blank"

  Scenario: Delete a payee from the link with javascript enabled
    Given a payee exists with email: "john@example.com"
    And I am on the payees page

    When I follow "Delete"

    Then I should be on the payees page
    And I should not see "john@example.com"

  Scenario: Delete a payee from the link with javascript disabled or manually navigate to the show page
    Given a payee exists with email: "john@example.com"
    And I am on the payees page

    When I go to the show page for that payeee

    Then I should see "Showing Payee: John"
    And I should see "john@example.com"
    And the "payee_submit" field should contain "Delete"

  Scenario: Delete a payee from the the show page
    Given a payee exists with email: "john@example.com"
    And I am on the show page for that payees

    When I press "Delete"

    Then I should be on the payees page
    And I should not see "john@example.com"

  Scenario: Cancel deleting a payee from the the show page
    Given a payee exists with email: "john@example.com"
    And I am on the show page for that payees

    When I follow "Cancel"

    Then I should be on the payees page
    And I should see "john@example.com"

