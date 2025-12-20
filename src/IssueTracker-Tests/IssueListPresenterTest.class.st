"
This test suite covers:
  - Initialization - presenter starts with no selection
  - items: - setting the items collection
  - selectItem:/selectedItem - selection management
  - unselectAll - clearing selection
  - computeDelay - delay calculation (with/without dependencies, nil dates)
  - formatDelay - delay formatting (dash vs +N)
  - formatStartDate - start date formatting (normal, nil)
  - formatDueDate - due date formatting (normal, nil)
  - Edge cases - empty items, selection after items change

"
Class {
	#name : 'IssueListPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'testIssue1',
		'testIssue2',
		'testIssue3',
		'dependentIssue',
		'mockOwner'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> setUp [
      super setUp.
      TestIssueRepository resetAll.
      IssueManager reset.
      IssueManager default repository: TestIssueRepository uniqueInstance.

      "Create mock owner"
      mockOwner := MockIssueListOwner new.

      "Create test issues"
      testIssue1 := Issue new
          title: 'First Issue';
          status: #open;
          priority: #high;
          startDate: Date today;
          duration: 5;
          yourself.

      testIssue2 := Issue new
          title: 'Second Issue';
          status: #inProgress;
          priority: #medium;
          startDate: Date today;
          duration: 3;
          yourself.

      testIssue3 := Issue new
          title: 'Closed Issue';
          status: #closed;
          priority: #low;
          startDate: (Date today subtractDays: 5);
          duration: 2;
          yourself.

      "Issue that depends on testIssue1 (will be delayed)"
      dependentIssue := Issue new
          title: 'Dependent Issue';
          status: #open;
          priority: #medium;
          startDate: Date today;
          duration: 2;
          yourself.
      dependentIssue addDependency: testIssue1.

      "Create presenter with mock owner"
      presenter := IssueListPresenter new.
      presenter owner: mockOwner.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> tearDown [
      presenter := nil.
      mockOwner := nil.
      testIssue1 := nil.
      testIssue2 := nil.
      testIssue3 := nil.
      dependentIssue := nil.
      IssueManager reset.
      TestIssueRepository resetAll.
      super tearDown.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testComputeDelayCalculatesCorrectDays [
      "Test computeDelay calculates the correct number of delay days"
      | delay expectedDelay |
      delay := presenter computeDelay: dependentIssue.
      expectedDelay := testIssue1 duration.
      self assert: delay equals: expectedDelay.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testComputeDelayNoDelay [
      "Test computeDelay returns 0 for issue without dependencies"
      | delay |
      delay := presenter computeDelay: testIssue1.
      self assert: delay equals: 0.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testComputeDelayWithDelay [
      "Test computeDelay returns positive value for delayed issue"
      | delay |
      delay := presenter computeDelay: dependentIssue.
      self assert: delay > 0.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testComputeDelayWithNilDates [
      "Test computeDelay handles nil dates gracefully"
      | issue delay |
      issue := Issue new title: 'No dates'; yourself.
      delay := presenter computeDelay: issue.
      self assert: delay equals: 0.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testEmptyItems [
      "Test setting empty items collection"
      presenter items: OrderedCollection new.
      self assert: presenter selectedItem isNil.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatDelayNoDelay [
      "Test formatDelay returns dash for non-delayed issue"
      | formatted |
      formatted := presenter formatDelay: testIssue1.
      self assert: formatted equals: '-'.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatDelayReturnsColoredText [
      "Test formatDelay returns colored Text for delayed issue"
      | formatted |
      formatted := presenter formatDelay: dependentIssue.
      self assert: (formatted isKindOf: Text).
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatDelayWithDelay [
      "Test formatDelay returns formatted string for delayed issue"
      | formatted |
      formatted := presenter formatDelay: dependentIssue.
      self assert: (formatted asString beginsWith: '+').
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatDueDate [
      "Test formatDueDate returns formatted date string"
      | issue formatted |
      issue := Issue new
          title: 'With due date';
          startDate: Date today;
          duration: 5;
          yourself.
      formatted := presenter formatDueDate: issue.
      self deny: formatted equals: '-'.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatDueDateWithNil [
      "Test formatDueDate handles issue without due date"
      | issue formatted |
      issue := Issue new
          title: 'No dates';
          yourself.
      formatted := presenter formatDueDate: issue.
      self assert: (formatted isString or: [ formatted isKindOf: Text ]).
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatStartDate [
      "Test formatStartDate returns formatted date string"
      | formatted |
      formatted := presenter formatStartDate: testIssue1.
      self deny: formatted equals: '-'.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatStartDateReturnsColoredTextForDelayed [
      "Test formatStartDate returns colored Text for delayed issue"
      | formatted |
      formatted := presenter formatStartDate: dependentIssue.
      self assert: (formatted isKindOf: Text).
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testFormatStartDateWithNil [
      "Test formatStartDate handles issue without start date"
      | issue formatted |
      issue := Issue new
          title: 'No dates';
          yourself.
      formatted := presenter formatStartDate: issue.
      "Should return computed date or dash"
      self assert: (formatted isString or: [ formatted isKindOf: Text ]).
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testInitialization [
      "Test that presenter initializes correctly"
      self assert: presenter selectedItem isNil.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testItems [
      "Test setting items"
      | issues |
      issues := OrderedCollection with: testIssue1 with: testIssue2.
      self shouldnt: [ presenter items: issues ] raise: Error.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testSelectAfterItemsChange [
      "Test that selection updates when items change"
      | issues |
      issues := OrderedCollection with: testIssue1 with: testIssue2.
      presenter items: issues.
      presenter selectItem: testIssue1.

      "Change items"
      presenter items: (OrderedCollection with: testIssue2).

      "Selection may be cleared or maintained based on implementation"
      self assert: (presenter selectedItem isNil or: [ presenter selectedItem = testIssue2 ]).
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testSelectItem [
      "Test selecting an item"
      | issues |
      issues := OrderedCollection with: testIssue1 with: testIssue2.
      presenter items: issues.

      presenter selectItem: testIssue1.
      self assert: presenter selectedItem equals: testIssue1.
      self assert: mockOwner selectedIssue equals: testIssue1.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testSelectionNotifiesOwner [
      "Test that selecting an item notifies the owner"
      | issues |
      issues := OrderedCollection with: testIssue1 with: testIssue2.
      presenter items: issues.

      presenter selectItem: testIssue2.
      self assert: mockOwner selectedIssue equals: testIssue2.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testUnselectAll [
      "Test unselecting all items"
      | issues |
      issues := OrderedCollection with: testIssue1 with: testIssue2.
      presenter items: issues.
      presenter selectItem: testIssue1.

      presenter unselectAll.
      self assert: presenter selectedItem isNil.
]

{ #category : 'as yet unclassified' }
IssueListPresenterTest >> testUnselectAllOnEmpty [
      "Test unselecting when nothing selected"
      self shouldnt: [ presenter unselectAll ] raise: Error.
      self assert: presenter selectedItem isNil.
]
