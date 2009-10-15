Feature: Scaffold new projects

As a developer I want to quickly scaffold new projects
So that I can skip the tedium of recreating standard directory structures

Scenario: Scaffold a new project
  Given I want to create a new "ruby" project
    And I want the project to be called "new_project"
    And I want to place it in a directory with the same name
  Given there is no project directory by that name
  When I execute sow
  Then a standard ruby project will be generated
    And with the proper project name
