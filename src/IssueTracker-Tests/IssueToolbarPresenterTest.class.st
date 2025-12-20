Class {
	#name : 'IssueToolbarPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'toolbar',
		'filterChangedCount'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> setUp [
      super setUp.
      TestIssueRepository resetAll.
      filterChangedCount := 0.
      toolbar := IssueToolbarPresenter new.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> tearDown [
      toolbar := nil.
      TestIssueRepository resetAll.
      super tearDown.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testEmptyIssueListTotalDuration [
      "Test that empty issue list returns 0 total duration"
      | issues total |

      issues := OrderedCollection new.

      total := issues
          inject: 0
          into: [ :sum :issue | sum + issue computedDuration ].

      self assert: total equals: 0.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testFractionalDurations [
      "Test that fractional durations are summed correctly"
      | issue1 issue2 issues total |

      issue1 := Issue new
          title: 'Half day';
          duration: 0.5;
          yourself.

      issue2 := Issue new
          title: 'Quarter day';
          duration: 0.25;
          yourself.

      issues := OrderedCollection with: issue1 with: issue2.

      total := issues
          inject: 0
          into: [ :sum :issue | sum + issue computedDuration ].

      self assert: total equals: 0.75.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testInitialDueDateFilter [
      "Test that due date filter defaults to #all"
      self assert: toolbar dueDateFilter equals: #all.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testInitialHideClosedIssues [
      "Test that hide closed issues defaults to false"
      self assert: toolbar hideClosedIssues equals: false.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testProjectedEndDate [
      "Test projected end date calculation"
      | issues total endDate expectedEnd |

      issues := OrderedCollection new.
      issues add: (Issue new duration: 5; yourself).
      issues add: (Issue new duration: 10; yourself).

      total := issues
          inject: 0
          into: [ :sum :issue | sum + issue computedDuration ].

      endDate := Date today addDays: total.
      expectedEnd := Date today addDays: 15.

      self assert: endDate equals: expectedEnd.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testStatusLabelWithNoOwner [
      "Test that refreshStatus handles nil owner gracefully"
      self shouldnt: [ toolbar refreshStatus ] raise: Error.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testTotalDurationCalculation [
      "Test total duration calculation for issues"
      | issue1 issue2 issues total |

      issue1 := Issue new
          title: 'Issue 1';
          duration: 5;
          yourself.

      issue2 := Issue new
          title: 'Issue 2';
          duration: 3;
          yourself.

      issues := OrderedCollection with: issue1 with: issue2.

      total := issues
          inject: 0
          into: [ :sum :issue | sum + issue computedDuration ].

      self assert: total equals: 8.
  
]

{ #category : 'as yet unclassified' }
IssueToolbarPresenterTest >> testTotalDurationWithDefaultDuration [
      "Test that issues without explicit duration use default of 1"
      | issue total |

      issue := Issue new
          title: 'No duration set';
          yourself.

      total := issue computedDuration.

      self assert: total equals: 1.
  
]
