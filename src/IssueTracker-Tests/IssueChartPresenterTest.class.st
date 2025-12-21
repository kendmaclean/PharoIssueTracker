Class {
	#name : 'IssueChartPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'testIssue1',
		'testIssue2',
		'testIssue3',
		'testIssue4'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> setUp [
      super setUp.
      TestIssueRepository resetAll.
      IssueManager reset.
      IssueManager default repository: TestIssueRepository uniqueInstance.

      "Create test issues with different statuses"
      testIssue1 := Issue new
          title: 'Open Issue';
          status: #open;
          priority: #high;
          yourself.

      testIssue2 := Issue new
          title: 'In Progress Issue';
          status: #inProgress;
          priority: #medium;
          yourself.

      testIssue3 := Issue new
          title: 'Closed Issue';
          status: #closed;
          priority: #low;
          yourself.

      testIssue4 := Issue new
          title: 'Resolved Issue';
          status: #resolved;
          priority: #medium;
          yourself.

      presenter := IssueChartPresenter new.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> tearDown [
      presenter := nil.
      testIssue1 := nil.
      testIssue2 := nil.
      testIssue3 := nil.
      testIssue4 := nil.
      IssueManager reset.
      TestIssueRepository resetAll.
      super tearDown.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testBuildChartOnWithAllStatuses [
      "Test buildChartOn:with: handles all four statuses"
      | canvas issues |
      canvas := RSCanvas new.
      issues := OrderedCollection
          with: testIssue1
          with: testIssue2
          with: testIssue3
          with: testIssue4.

      presenter buildChartOn: canvas with: issues.

      "Should have 4 composite shapes (one per status)"
      self assert: canvas shapes size equals: 4.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testBuildChartOnWithDoesNotModifyCollection [
      "Test buildChartOn:with: does not modify the passed collection"
      | canvas issues originalSize |
      canvas := RSCanvas new.
      issues := OrderedCollection with: testIssue1 with: testIssue2.
      originalSize := issues size.

      presenter buildChartOn: canvas with: issues.

      self assert: issues size equals: originalSize.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testBuildChartOnWithEmptyCollection [
      "Test buildChartOn:with: shows empty message for empty collection"
      | canvas |
      canvas := RSCanvas new.

      presenter buildChartOn: canvas with: OrderedCollection new.

      self assert: canvas shapes size equals: 1.
      self assert: (canvas shapes first isKindOf: RSLabel).
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testBuildChartOnWithIssues [
      "Test buildChartOn:with: creates chart elements"
      | canvas issues |
      canvas := RSCanvas new.
      issues := OrderedCollection with: testIssue1 with: testIssue2.

      presenter buildChartOn: canvas with: issues.

      self assert: canvas shapes isNotEmpty.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testBuildChartOnWithMultipleSameStatus [
      "Test buildChartOn:with: counts multiple issues of same status"
      | canvas issues anotherOpen |
      canvas := RSCanvas new.

      anotherOpen := Issue new
          title: 'Another Open';
          status: #open;
          yourself.

      issues := OrderedCollection with: testIssue1 with: anotherOpen.

      presenter buildChartOn: canvas with: issues.

      self assert: canvas shapes isNotEmpty.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testBuildChartOnWithSingleStatus [
      "Test buildChartOn:with: works with issues of only one status"
      | canvas issues |
      canvas := RSCanvas new.
      issues := OrderedCollection with: testIssue1.

      presenter buildChartOn: canvas with: issues.

      self assert: canvas shapes isNotEmpty.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusBlocked [
      "Test colorForStatus returns red for blocked"
      self assert: (presenter colorForStatus: #blocked) equals: Color red.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusClosed [
      "Test colorForStatus returns gray for closed"
      self assert: (presenter colorForStatus: #closed) equals: Color gray.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusInProgress [
      "Test colorForStatus returns orange for inProgress"
      self assert: (presenter colorForStatus: #inProgress) equals: Color orange.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusMilestone [
      "Test colorForStatus returns yellow for milestone"
      self assert: (presenter colorForStatus: #milestone) equals: Color yellow.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusOpen [
      "Test colorForStatus returns cyan for open"
      self assert: (presenter colorForStatus: #open) equals: Color cyan.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusResolved [
      "Test colorForStatus returns green for resolved"
      self assert: (presenter colorForStatus: #resolved) equals: Color green.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testColorForStatusUnknown [
      "Test colorForStatus returns default for unknown status"
      self assert: (presenter colorForStatus: #unknownStatus) equals: Color lightGray.
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testShowEmptyMessageOn [
      "Test showEmptyMessageOn creates label on canvas"
      | canvas |
      canvas := RSCanvas new.

      presenter showEmptyMessageOn: canvas.

      self assert: canvas shapes isNotEmpty.
      self assert: (canvas shapes first isKindOf: RSLabel).
]

{ #category : 'as yet unclassified' }
IssueChartPresenterTest >> testShowEmptyMessageOnLabelText [
      "Test showEmptyMessageOn creates label with correct text"
      | canvas label |
      canvas := RSCanvas new.

      presenter showEmptyMessageOn: canvas.

      label := canvas shapes first.
      self assert: label text equals: 'No issues to display'.
]
