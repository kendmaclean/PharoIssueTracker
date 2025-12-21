"
This test suite covers:

  | Category       | Tests                                                                                                            |
  |----------------|------------------------------------------------------------------------------------------------------------------|
  | Initialization | Components created, initial state, default values for priority/status                                            |
  | loadIssue:     | Title, description, status, priority, startDate, dueDate, duration population; nil handling; no callback trigger |
  | clearForm      | Resets all fields to defaults                                                                                    |
  | Accessors      | selectedDuration parsing (numbers, empty, invalid, whitespace, decimals), hasCurrentIssue                        |
  | Actions        | deleteIssue calls owner                                                                                          |
  | Layout         | defaultLayout, buildLayoutWithDependencies:                                                                      |
  | Button States  | Delete button enabled/disabled based on current issue                                                            |
  | Auto-Calculate | Date calculations from start+duration, skip during loading                                                       |
  | Dependencies   | Button initialization, loadDependencies:                                                                         |
  | Dropdowns      | Priority and status items                                                                                        |
  | Window         | Title and initial extent                                                                                         |

"
Class {
	#name : 'IssueDetailsPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'mockOwner',
		'testIssue',
		'testIssue2'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IssueDetailsPresenterTest >> setUp [
      super setUp.
      TestIssueRepository resetAll.
      IssueManager reset.
      IssueManager default repository: TestIssueRepository uniqueInstance.

      "Create mock owner"
      mockOwner := MockIssueDetailsOwner new.

      "Create test issues"
      testIssue := Issue new
          title: 'Test Issue';
          description: 'Test description';
          status: #inProgress;
          priority: #high;
          startDate: Date today;
          duration: 5;
          dueDate: (Date today addDays: 5);
          yourself.

      testIssue2 := Issue new
          title: 'Second Issue';
          description: 'Another description';
          status: #open;
          priority: #low;
          startDate: (Date today addDays: 10);
          duration: 3;
          yourself.

      "Add issues to repository"
      TestIssueRepository uniqueInstance addIssue: testIssue.
      TestIssueRepository uniqueInstance addIssue: testIssue2.

      "Create presenter with mock owner"
      presenter := IssueDetailsPresenter new.
      presenter owner: mockOwner.
  
]

{ #category : 'running' }
IssueDetailsPresenterTest >> tearDown [
      presenter := nil.
      mockOwner := nil.
      testIssue := nil.
      testIssue2 := nil.
      IssueManager reset.
      TestIssueRepository resetAll.
      super tearDown.
  
]

{ #category : 'tests-autoCalculate' }
IssueDetailsPresenterTest >> testAutoCalculateDatesFromStartAndDuration [
      "Test due date calculation from start date and duration"
      | startDateInput durationInput dueDateInput |
      startDateInput := presenter instVarNamed: #startDateInput.
      durationInput := presenter instVarNamed: #durationInput.
      dueDateInput := presenter instVarNamed: #dueDateInput.

      "Set start date"
      startDateInput date: Date today.

      "Set duration - this should trigger auto-calculation"
      presenter instVarNamed: #lastChangedField put: #startDate.
      durationInput text: '7'.

      presenter autoCalculateDates.

      "Due date should be calculated"
      self assert: dueDateInput date equals: (Date today addDays: 7).
  
]

{ #category : 'tests-autoCalculate' }
IssueDetailsPresenterTest >> testAutoCalculateDatesSkipsWhenLoading [
      "Test that autoCalculateDates does nothing when loading an issue"
      | startDateInput durationInput dueDateInput |
      startDateInput := presenter instVarNamed: #startDateInput.
      durationInput := presenter instVarNamed: #durationInput.
      dueDateInput := presenter instVarNamed: #dueDateInput.

      presenter instVarNamed: #isLoadingIssue put: true.

      startDateInput date: Date today.
      durationInput text: '7'.
      presenter instVarNamed: #lastChangedField put: #startDate.

      "Store original due date"
      dueDateInput date: nil.

      presenter autoCalculateDates.

      "Due date should NOT be calculated"
      self assert: dueDateInput date isNil.
  
]

{ #category : 'tests-layout' }
IssueDetailsPresenterTest >> testBuildLayoutWithDependencies [
      "Test that buildLayoutWithDependencies returns valid layout"
      | layout |
      layout := presenter buildLayoutWithDependencies: false.

      self deny: layout isNil.
      self assert: (layout isKindOf: SpBoxLayout).
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsDescription [
      "Test that clearForm resets the description"
      presenter loadIssue: testIssue.
      presenter clearForm.
      self assert: presenter descriptionText equals: ''.
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsDueDate [
      "Test that clearForm clears the due date"
      presenter loadIssue: testIssue.
      presenter clearForm.
      self assert: presenter selectedDueDate isNil.
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsDuration [
      "Test that clearForm clears the duration"
      presenter loadIssue: testIssue.
      presenter clearForm.
      self assert: presenter selectedDuration isNil.
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsPriority [
      "Test that clearForm resets priority to medium"
      presenter loadIssue: testIssue.
      presenter clearForm.
      self assert: presenter selectedPriority equals: #medium.
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsStartDateToToday [
      "Test that clearForm resets start date to today"
      presenter loadIssue: testIssue2. "Issue with future start date"
      presenter clearForm.
      self assert: presenter selectedStartDate equals: Date today.
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsStatus [
      "Test that clearForm resets status to open"
      presenter loadIssue: testIssue.
      presenter clearForm.
      self assert: presenter selectedStatus equals: #open.
  
]

{ #category : 'tests-clearForm' }
IssueDetailsPresenterTest >> testClearFormResetsTitle [
      "Test that clearForm resets the title"
      presenter loadIssue: testIssue.
      presenter clearForm.
      self assert: presenter titleText equals: ''.
  
]

{ #category : 'tests-layout' }
IssueDetailsPresenterTest >> testDefaultLayout [
      "Test that default layout is valid"
      | layout |
      layout := presenter defaultLayout.

      self deny: layout isNil.
      self assert: (layout isKindOf: SpBoxLayout).
  
]

{ #category : 'tests-initialization' }
IssueDetailsPresenterTest >> testDefaultPriorityIsMedium [
      "Test that default priority is medium"
      self assert: presenter selectedPriority equals: #medium.
  
]

{ #category : 'tests-initialization' }
IssueDetailsPresenterTest >> testDefaultStatusIsOpen [
      "Test that default status is open"
      self assert: presenter selectedStatus equals: #open.
  
]

{ #category : 'tests-actions' }
IssueDetailsPresenterTest >> testDeleteIssueCallsOwner [
      "Test that deleteIssue calls owner deleteCurrentIssue"
      mockOwner currentIssue: testIssue.
      presenter deleteIssue.
      self assert: mockOwner deleteRequestCount equals: 1.
  
]

{ #category : 'tests-dependencies' }
IssueDetailsPresenterTest >> testEnsureDependenciesInitializedIdempotent [
      "Test that calling ensureDependenciesInitialized multiple times is safe"
      "Note: buttons are created during initializePresenters, this tests idempotency"
      | addBtn1 removeBtn1 |

      "Get current state"
      addBtn1 := presenter instVarNamed: #addDependencyButton.
      removeBtn1 := presenter instVarNamed: #removeDependencyButton.

      "Call ensure - should not fail or change existing buttons"
      presenter ensureDependenciesInitialized.

      "Verify idempotency - same objects"
      addBtn1 ifNotNil: [
          self assert: (presenter instVarNamed: #addDependencyButton) identicalTo: addBtn1 ].
      removeBtn1 ifNotNil: [
          self assert: (presenter instVarNamed: #removeDependencyButton) identicalTo: removeBtn1 ].
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testHasCurrentIssueWhenNone [
      "Test hasCurrentIssue returns false when no issue selected"
      mockOwner currentIssue: nil.
      self deny: presenter hasCurrentIssue.
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testHasCurrentIssueWhenSelected [
      "Test hasCurrentIssue returns true when issue is selected"
      mockOwner currentIssue: testIssue.
      self assert: presenter hasCurrentIssue.
  
]

{ #category : 'tests-initialization' }
IssueDetailsPresenterTest >> testInitialStateIsNotLoading [
      "Test that isLoadingIssue starts as false"
      self deny: (presenter instVarNamed: #isLoadingIssue).
  
]

{ #category : 'tests-initialization' }
IssueDetailsPresenterTest >> testInitialization [
      "Test that presenter initializes with all components"
      self deny: presenter isNil.
      self assert: (presenter instVarNamed: #titleInput) notNil.
      self assert: (presenter instVarNamed: #descriptionInput) notNil.
      self assert: (presenter instVarNamed: #priorityDropdown) notNil.
      self assert: (presenter instVarNamed: #statusDropdown) notNil.
      self assert: (presenter instVarNamed: #startDateInput) notNil.
      self assert: (presenter instVarNamed: #dueDateInput) notNil.
      self assert: (presenter instVarNamed: #durationInput) notNil.
      self assert: (presenter instVarNamed: #addButton) notNil.
      self assert: (presenter instVarNamed: #deleteButton) notNil.
  
]

{ #category : 'tests-dependencies' }
IssueDetailsPresenterTest >> testLoadDependenciesDoesNotFail [
      "Test that loadDependencies handles any issue"
      self shouldnt: [ presenter loadDependencies: testIssue ] raise: Error.
      self shouldnt: [ presenter loadDependencies: nil ] raise: Error.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssueDoesNotTriggerFieldChanged [
      "Test that loadIssue does not trigger fieldChanged callback"
      presenter loadIssue: testIssue.
      self assert: mockOwner fieldChangedCount equals: 0.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesDescription [
      "Test that loadIssue sets the description field"
      presenter loadIssue: testIssue.
      self assert: presenter descriptionText equals: 'Test description'.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesDueDate [
      "Test that loadIssue sets the due date field"
      presenter loadIssue: testIssue.
      self assert: presenter selectedDueDate equals: (Date today addDays: 5).
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesDuration [
      "Test that loadIssue sets the duration field"
      presenter loadIssue: testIssue.
      self assert: presenter selectedDuration equals: 5.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesPriority [
      "Test that loadIssue sets the priority dropdown"
      presenter loadIssue: testIssue.
      self assert: presenter selectedPriority equals: #high.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesStartDate [
      "Test that loadIssue sets the start date field"
      presenter loadIssue: testIssue.
      self assert: presenter selectedStartDate equals: Date today.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesStatus [
      "Test that loadIssue sets the status dropdown"
      presenter loadIssue: testIssue.
      self assert: presenter selectedStatus equals: #inProgress.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssuePopulatesTitle [
      "Test that loadIssue sets the title field"
      presenter loadIssue: testIssue.
      self assert: presenter titleText equals: 'Test Issue'.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssueWithNilDescription [
      "Test that loadIssue handles nil description"
      | issueWithNilDesc |
      issueWithNilDesc := Issue new
          title: 'No Description';
          yourself.

      self shouldnt: [ presenter loadIssue: issueWithNilDesc ] raise: Error.
      self assert: presenter descriptionText equals: ''.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadIssueWithNilDuration [
      "Test that loadIssue handles nil duration"
      | issueWithNilDuration |
      issueWithNilDuration := Issue new
          title: 'No Duration';
          yourself.

      self shouldnt: [ presenter loadIssue: issueWithNilDuration ] raise: Error.
      self assert: presenter selectedDuration isNil.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadMultipleIssuesSequentially [
      "Test loading different issues updates the form correctly"
      presenter loadIssue: testIssue.
      self assert: presenter titleText equals: 'Test Issue'.
      self assert: presenter selectedPriority equals: #high.

      presenter loadIssue: testIssue2.
      self assert: presenter titleText equals: 'Second Issue'.
      self assert: presenter selectedPriority equals: #low.
  
]

{ #category : 'tests-loadIssue' }
IssueDetailsPresenterTest >> testLoadNilIssue [
      "Test that loadIssue handles nil gracefully"
      presenter loadIssue: testIssue.
      self shouldnt: [ presenter loadIssue: nil ] raise: Error.
  
]

{ #category : 'tests-dropdowns' }
IssueDetailsPresenterTest >> testPriorityDropdownItems [
      "Test that priority dropdown has correct items"
      | priorityDropdown |
      priorityDropdown := presenter instVarNamed: #priorityDropdown.

      self assert: priorityDropdown items equals: #( low medium high critical ).
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testSelectedDurationHandlesDecimal [
      "Test that selectedDuration handles decimal values"
      | durationInput |
      durationInput := presenter instVarNamed: #durationInput.
      durationInput text: '2.5'.
      self assert: presenter selectedDuration equals: 2.5.
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testSelectedDurationHandlesEmpty [
      "Test that selectedDuration returns nil for empty text"
      | durationInput |
      durationInput := presenter instVarNamed: #durationInput.
      durationInput text: ''.
      self assert: presenter selectedDuration isNil.
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testSelectedDurationHandlesInvalidText [
      "Test that selectedDuration returns nil for non-numeric text"
      | durationInput |
      durationInput := presenter instVarNamed: #durationInput.
      durationInput text: 'abc'.
      self assert: presenter selectedDuration isNil.
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testSelectedDurationHandlesWhitespace [
      "Test that selectedDuration trims whitespace"
      | durationInput |
      durationInput := presenter instVarNamed: #durationInput.
      durationInput text: '  5  '.
      self assert: presenter selectedDuration equals: 5.
  
]

{ #category : 'tests-accessors' }
IssueDetailsPresenterTest >> testSelectedDurationParsesNumber [
      "Test that selectedDuration parses numeric text"
      | durationInput |
      durationInput := presenter instVarNamed: #durationInput.
      durationInput text: '10'.
      self assert: presenter selectedDuration equals: 10.
  
]

{ #category : 'tests-dropdowns' }
IssueDetailsPresenterTest >> testStatusDropdownItems [
      "Test that status dropdown has correct items"
      | statusDropdown |
      statusDropdown := presenter instVarNamed: #statusDropdown.

      self assert: statusDropdown items equals: #( open inProgress resolved closed milestone ).
  
]

{ #category : 'tests-buttonStates' }
IssueDetailsPresenterTest >> testUpdateButtonStatesWithCurrentIssue [
      "Test delete button is enabled when issue is selected"
      | deleteButton |
      mockOwner currentIssue: testIssue.
      presenter updateButtonStates.

      deleteButton := presenter instVarNamed: #deleteButton.
      self assert: deleteButton isEnabled.
  
]

{ #category : 'tests-buttonStates' }
IssueDetailsPresenterTest >> testUpdateButtonStatesWithNoCurrentIssue [
      "Test delete button is disabled when no issue selected"
      | deleteButton |
      mockOwner currentIssue: nil.
      presenter updateButtonStates.

      deleteButton := presenter instVarNamed: #deleteButton.
      self deny: deleteButton isEnabled.
  
]

{ #category : 'tests-window' }
IssueDetailsPresenterTest >> testWindowConfiguration [
      "Test window initialization"
      | window |
      window := presenter asWindow.

      self assert: window title equals: 'Issue Tracker - Gantt View'.
      self assert: window initialExtent equals: 1200 @ 800.
  
]
