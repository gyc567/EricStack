@auth @smoke
Feature: User Login
  As a registered user
  I want to log in with my credentials
  So that I can access my account

  Background:
    Given the user is on the login page

  @regression
  Scenario: Successful login with valid credentials
    When the user enters username "alice" and password "secret123"
    Then the user should be redirected to the dashboard
    And the user should see a welcome message

  @regression @sad-path
  Scenario: Failed login with wrong password
    When the user enters username "alice" and password "wrongpassword"
    Then the user should see an error message "Invalid credentials"
    And the user should remain on the login page

  @smoke
  Scenario Outline: Login attempts with various credentials
    When the user enters username "<username>" and password "<password>"
    Then the result should be "<result>"

    Examples:
      | username | password    | result                        |
      | alice    | secret123   | redirected to dashboard       |
      | bob      | pass456     | redirected to dashboard       |
      | alice    | wrongpass   | error: Invalid credentials    |
      | unknown  | secret123   | error: User not found         |
