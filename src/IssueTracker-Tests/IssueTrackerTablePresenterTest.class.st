"
This test suite covers:
  - Initialization - presenter starts with no selection
  - hasCurrentIssue - boolean check for selection state
  - currentIssue - accessor for selected issue
  - onIssueSelected - selecting issues updates state
  - clearCurrentIssue - clearing selection
  - getFilteredIssues - returns filtered issue list
  - issueListChanged - refreshes from manager
  - filterChanged - handles filter updates

"
Class {
	#name : 'IssueTrackerTablePresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'testIssue1',
		'testIssue2',
		'testIssue3'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> setUp [

	super setUp.
	TestIssueRepository resetAll.
	IssueManager reset.
	
	IssueManager reset.
	"Point IssueManager to test repository"
	IssueManager default repository: TestIssueRepository uniqueInstance.

	"Create test issues"
	testIssue1 := Issue new
		              title: 'First Issue';
		              status: #open;
		              priority: #high;
		              duration: 5;
		              yourself.

	testIssue2 := Issue new
		              title: 'Second Issue';
		              status: #inProgress;
		              priority: #medium;
		              duration: 3;
		              yourself.

	testIssue3 := Issue new
		              title: 'Closed Issue';
		              status: #closed;
		              priority: #low;
		              duration: 2;
		              yourself.

	"Add via test repository"
	TestIssueRepository uniqueInstance addIssue: testIssue1.
	TestIssueRepository uniqueInstance addIssue: testIssue2.
	TestIssueRepository uniqueInstance addIssue: testIssue3.

	presenter := IssueTrackerTablePresenter new
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> tearDown [
      presenter := nil.
      testIssue1 := nil.
      testIssue2 := nil.
      testIssue3 := nil.
      IssueManager reset.
      TestIssueRepository resetAll.
      super tearDown.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testClearCurrentIssue [
      "Test clearing the current issue"
      presenter onIssueSelected: testIssue1.
      self assert: presenter hasCurrentIssue.

      presenter clearCurrentIssue.
      self deny: presenter hasCurrentIssue.
      self assert: presenter currentIssue isNil.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testCurrentIssueAccessor [
      "Test currentIssue getter"
      self assert: presenter currentIssue isNil.
      presenter onIssueSelected: testIssue1.
      self assert: presenter currentIssue equals: testIssue1.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testFilterChanged [
      "Test that filterChanged does not raise error"
      self shouldnt: [ presenter filterChanged ] raise: Error.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testGetFilteredIssuesExcludesClosed [
      "Test that getFilteredIssues excludes closed issues when filter is set"
      | filtered toolbar |
      "Access toolbar via instVar and toggle hide closed"
      toolbar := presenter instVarNamed: 'toolbar'.
      toolbar instVarNamed: 'hideClosedIssues' put: true.

      filtered := presenter getFilteredIssues.
      self assert: (filtered noneSatisfy: [ :i | i status = #closed ]).
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testGetFilteredIssuesReturnsAll [
      "Test that getFilteredIssues returns all issues with default filter"
      | filtered |
      filtered := presenter getFilteredIssues.
      self assert: filtered size equals: 3.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testHasCurrentIssueWhenNil [
      "Test hasCurrentIssue returns false when no issue selected"
      self deny: presenter hasCurrentIssue.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testHasCurrentIssueWhenSet [
      "Test hasCurrentIssue returns true when issue is selected"
      presenter onIssueSelected: testIssue1.
      self assert: presenter hasCurrentIssue.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testInitialization [
      "Test that presenter initializes correctly"
      self assert: presenter currentIssue isNil.
      self deny: presenter hasCurrentIssue.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testIssueListChanged [
      "Test that issueListChanged reloads issues from manager"
      | newIssue |
      newIssue := Issue new
          title: 'New Issue';
          status: #open;
          yourself.

      TestIssueRepository uniqueInstance addIssue: newIssue.
      presenter issueListChanged.

      self assert: presenter getFilteredIssues size equals: 4.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testMultipleIssueSelections [
      "Test switching between issues"
      presenter onIssueSelected: testIssue1.
      self assert: presenter currentIssue title equals: 'First Issue'.

      presenter onIssueSelected: testIssue2.
      self assert: presenter currentIssue title equals: 'Second Issue'.

      presenter onIssueSelected: testIssue3.
      self assert: presenter currentIssue title equals: 'Closed Issue'.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testOnIssueSelected [
      "Test that selecting an issue updates currentIssue"
      presenter onIssueSelected: testIssue2.
      self assert: presenter currentIssue equals: testIssue2.

      presenter onIssueSelected: testIssue1.
      self assert: presenter currentIssue equals: testIssue1.
]

{ #category : 'as yet unclassified' }
IssueTrackerTablePresenterTest >> testOnIssueSelectedWithNil [
      "Test that selecting nil clears selection"
      presenter onIssueSelected: testIssue1.
      self assert: presenter hasCurrentIssue.

      presenter onIssueSelected: nil.
      self assert: presenter currentIssue isNil.
]
