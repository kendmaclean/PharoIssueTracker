"
This test suite covers:

  | Test                                        | Description                             |
  |---------------------------------------------|-----------------------------------------|
  | testInitialization                          | Verifies all components are created     |
  | testIssueAssignment                         | Tests setting the issue                 |
  | testRefreshDependenciesShowsAllDependencies | Tests dependency list population        |
  | testRefreshDependenciesWithNoDependencies   | Tests empty dependency case             |
  | testOnDependencyChangedCallback             | Tests callback storage                  |
  | testRemoveDependencyWithNoSelection         | Tests graceful handling of no selection |
  | testRemoveDependencyWithSelection           | Tests actual dependency removal         |
  | testRemoveDependencyTriggersCallback        | Tests callback execution                |
  | testRemoveDependencyUpdatesListDisplay      | Tests list refresh after removal        |
  | testRemoveDependencyWithNilIssue            | Tests nil issue handling                |
  | testAddDependencyWithNilIssue               | Tests nil issue handling for add        |
  | testIssueAssignmentWithNil                  | Tests setting nil issue                 |
  | testDefaultLayout                           | Tests layout creation                   |
  | testWindowInitialization                    | Tests window configuration              |
  | testMultipleRemoveDependencies              | Tests removing all dependencies         |
  | testCallbackNotTriggeredWhenNotSet          | Tests no error when callback is nil     |

  Note: The addDependency method uses UIManager default chooseFrom:values:title: which requires user interaction, making it difficult to fully test without mocking the UIManager. The tests focus on the testable parts of the dialog.

"
Class {
	#name : 'IssueDependencyDialogTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'testIssue',
		'dependency1',
		'dependency2',
		'callbackExecuted'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IssueDependencyDialogTest >> setUp [
      super setUp.
      TestIssueRepository resetAll.
      IssueManager reset.
      IssueManager default repository: TestIssueRepository uniqueInstance.

      "Create test issues"
      dependency1 := Issue new
          title: 'Dependency One';
          status: #open;
          priority: #high;
          startDate: Date today;
          duration: 3;
          yourself.

      dependency2 := Issue new
          title: 'Dependency Two';
          status: #inProgress;
          priority: #medium;
          startDate: Date today;
          duration: 5;
          yourself.

      testIssue := Issue new
          title: 'Main Issue';
          status: #open;
          priority: #medium;
          startDate: Date today;
          duration: 2;
          yourself.

      "Add dependencies to main issue"
      testIssue addDependency: dependency1.
      testIssue addDependency: dependency2.

      "Add all issues to repository"
      TestIssueRepository uniqueInstance addIssue: dependency1.
      TestIssueRepository uniqueInstance addIssue: dependency2.
      TestIssueRepository uniqueInstance addIssue: testIssue.

      "Initialize callback tracker"
      callbackExecuted := false.

      "Create the presenter"
      presenter := IssueDependencyDialog new.
  
]

{ #category : 'running' }
IssueDependencyDialogTest >> tearDown [
      presenter := nil.
      testIssue := nil.
      dependency1 := nil.
      dependency2 := nil.
      callbackExecuted := nil.
      IssueManager reset.
      TestIssueRepository resetAll.
      super tearDown.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testAddDependencyWithNilIssue [
      "Test that addDependency handles nil issue gracefully"
      "Do not set issue"
      self shouldnt: [ presenter addDependency ] raise: Error.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testCallbackNotTriggeredWhenNotSet [
      "Test that removing dependency without callback set does not fail"
      | dependenciesList |
      presenter issue: testIssue.
      "Explicitly do NOT set callback"
      dependenciesList := presenter instVarNamed: #dependenciesList.

      dependenciesList selectItem: dependency1.

      "Should not raise error"
      self shouldnt: [ presenter removeDependency ] raise: Error.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testDefaultLayout [
      "Test that default layout is valid"
      | layout |
      layout := presenter defaultLayout.

      self deny: layout isNil.
      self assert: (layout isKindOf: SpBoxLayout).
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testInitialization [
      "Test that presenter initializes correctly with all components"
      self deny: presenter isNil.
      self assert: (presenter instVarNamed: #dependenciesList) notNil.
      self assert: (presenter instVarNamed: #addButton) notNil.
      self assert: (presenter instVarNamed: #removeButton) notNil.
      self assert: (presenter instVarNamed: #onDependencyChangedBlock) isNil.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testIssueAssignment [
      "Test that assigning an issue updates the presenter"
      presenter issue: testIssue.
      self assert: (presenter instVarNamed: #issue) equals: testIssue.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testIssueAssignmentWithNil [
      "Test setting issue to nil"
      presenter issue: testIssue.
      presenter issue: nil.

      self assert: (presenter instVarNamed: #issue) isNil.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testMultipleRemoveDependencies [
      "Test removing all dependencies one by one"
      | dependenciesList |
      presenter issue: testIssue.
      dependenciesList := presenter instVarNamed: #dependenciesList.

      "Remove first dependency"
      dependenciesList selectItem: dependency1.
      presenter removeDependency.

      "Remove second dependency"
      dependenciesList selectItem: dependency2.
      presenter removeDependency.

      "Should have no dependencies left"
      self assert: testIssue dependencies isEmpty.
      self assert: dependenciesList items isEmpty.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testOnDependencyChangedCallback [
      "Test that callback block is stored correctly"
      | block |
      block := [ callbackExecuted := true ].
      presenter onDependencyChanged: block.

      self assert: (presenter instVarNamed: #onDependencyChangedBlock) equals: block.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRefreshDependenciesShowsAllDependencies [
      "Test that refreshDependencies populates the list with issue dependencies"
      | dependenciesList |
      presenter issue: testIssue.
      dependenciesList := presenter instVarNamed: #dependenciesList.

      self assert: dependenciesList items size equals: 2.
      self assert: (dependenciesList items includes: dependency1).
      self assert: (dependenciesList items includes: dependency2).
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRefreshDependenciesWithNoDependencies [
      "Test that issue without dependencies shows empty list"
      | issueWithNoDeps dependenciesList |
      issueWithNoDeps := Issue new
          title: 'No Dependencies';
          status: #open;
          yourself.

      presenter issue: issueWithNoDeps.
      dependenciesList := presenter instVarNamed: #dependenciesList.

      self assert: dependenciesList items isEmpty.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRemoveDependencyTriggersCallback [
      "Test that removeDependency triggers the callback when set"
      | dependenciesList |
      presenter issue: testIssue.
      presenter onDependencyChanged: [ callbackExecuted := true ].
      dependenciesList := presenter instVarNamed: #dependenciesList.

      "Select a dependency"
      dependenciesList selectItem: dependency1.

      "Remove it"
      presenter removeDependency.

      "Callback should have been executed"
      self assert: callbackExecuted.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRemoveDependencyUpdatesListDisplay [
      "Test that the list is refreshed after removing a dependency"
      | dependenciesList |
      presenter issue: testIssue.
      dependenciesList := presenter instVarNamed: #dependenciesList.

      "Select and remove first dependency"
      dependenciesList selectItem: dependency1.
      presenter removeDependency.

      "List should now show only one item"
      self assert: dependenciesList items size equals: 1.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRemoveDependencyWithNilIssue [
      "Test that removeDependency handles nil issue gracefully"
      "Do not set issue"
      self shouldnt: [ presenter removeDependency ] raise: Error.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRemoveDependencyWithNoSelection [
      "Test that removeDependency handles no selection gracefully"
      presenter issue: testIssue.

      "Should not raise an error when no selection"
      self shouldnt: [ presenter removeDependency ] raise: Error.

      "Dependencies should remain unchanged"
      self assert: testIssue dependencies size equals: 2.
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testRemoveDependencyWithSelection [
      "Test that removeDependency removes the selected dependency"
      | dependenciesList |
      presenter issue: testIssue.
      dependenciesList := presenter instVarNamed: #dependenciesList.

      "Select the first dependency"
      dependenciesList selectItem: dependency1.

      "Remove the selected dependency"
      presenter removeDependency.

      "Check that dependency was removed"
      self assert: testIssue dependencies size equals: 1.
      self deny: (testIssue dependencies includes: dependency1).
      self assert: (testIssue dependencies includes: dependency2).
  
]

{ #category : 'tests' }
IssueDependencyDialogTest >> testWindowInitialization [
      "Test that window is configured correctly"
      | window |
      presenter issue: testIssue.

      "Create window but don't open it"
      window := presenter asWindow.

      self assert: window title equals: 'Manage Dependencies'.
      self assert: window initialExtent equals: 500 @ 400.
  
]
