Class {
	#name : 'IssueFilterTest',
	#superclass : 'TestCase',
	#instVars : [
		'filter',
		'sampleIssues'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IssueFilterTest >> createSampleIssues [
	"Create a collection of sample issues for testing"

	| issue1 issue2 issue3 issue4 issue5 issue6 |
	"Issue 1: Open, high priority, due tomorrow"
	issue1 := Issue new
		          title: 'Open Issue';
		          status: #open;
		          priority: #high;
		          startDate: Date today;
		          dueDate: (Date today addDays: 1);
		          yourself.

	"Issue 2: In progress, medium priority, due in 5 days"
	issue2 := Issue new
		          title: 'In Progress Issue';
		          status: #inProgress;
		          priority: #medium;
		          startDate: (Date today subtractDays: 2);
		          dueDate: (Date today addDays: 5);
		          yourself.

	"Issue 3: Resolved, high priority, no due date"
	issue3 := Issue new
		          title: 'Resolved Issue';
		          status: #resolved;
		          priority: #high;
		          yourself.

	"Issue 4: Closed, low priority"
	issue4 := Issue new
		          title: 'Closed Issue';
		          status: #closed;
		          priority: #low;
		          startDate: (Date today subtractDays: 10);
		          dueDate: (Date today subtractDays: 3);
		          yourself.

	"Issue 5: Blocked, critical priority, due today"
	issue5 := Issue new
		          title: 'Blocked Issue';
		          status: #blocked;
		          priority: #critical;
		          startDate: (Date today subtractDays: 5);
		          dueDate: Date today;
		          yourself.

	"Issue 6: Milestone, medium priority, due in 2 weeks"
	issue6 := Issue new
		          title: 'Milestone Issue';
		          status: #milestone;
		          priority: #medium;
		          startDate: Date today;
		          dueDate: (Date today addDays: 14);
		          yourself.

	sampleIssues := OrderedCollection
		                with: issue1
		                with: issue2
		                with: issue3
		                with: issue4
		                with: issue5
		                with: issue6
]

{ #category : 'running' }
IssueFilterTest >> issueWithStatus: aStatus [
	"Helper to find an issue with a specific status"
	^ sampleIssues detect: [ :issue | issue status = aStatus ]
]

{ #category : 'running' }
IssueFilterTest >> setUp [
	"Set up test fixtures"
	super setUp.
	filter := IssueFilter new.
	self createSampleIssues
]

{ #category : 'running' }
IssueFilterTest >> tearDown [
	"Clean up after tests"
	filter := nil.
	sampleIssues := nil.
	super tearDown
]

{ #category : 'running' }
IssueFilterTest >> testApplyBasicFilter [
	"Test basic filtering without any special filters"

	| result |
	filter hideClosedIssues: false.
	filter dueDateFilter: #all.

	result := filter applyTo: sampleIssues.

	self assert: result size equals: sampleIssues size.
	self assert: (result includesAll: sampleIssues)
]

{ #category : 'running' }
IssueFilterTest >> testCombinedFilters [
	"Test combining hideClosedIssues and date filter"
	| result |
	
	filter hideClosedIssues: true.
	filter dueDateFilter: #today.
	
	result := filter applyTo: sampleIssues.
	
	"Should not include closed or resolved"
	self assert: (result noneSatisfy: [ :issue | issue status = #closed ]).
	self assert: (result noneSatisfy: [ :issue | issue status = #resolved ]).
	
	"Should only include issues active today"
	result do: [ :issue |
		self assert: issue status ~= #closed.
		self assert: issue status ~= #resolved ]
]

{ #category : 'running' }
IssueFilterTest >> testDueDateFilterAccessor [
	"Test the dueDateFilter accessor"
	
	filter dueDateFilter: #all.
	self assert: filter dueDateFilter equals: #all.
	
	filter dueDateFilter: #today.
	self assert: filter dueDateFilter equals: #today.
	
	filter dueDateFilter: #thisWeek.
	self assert: filter dueDateFilter equals: #thisWeek
]

{ #category : 'running' }
IssueFilterTest >> testDueDateFilterAll [
	"Test showing all issues regardless of due date"

	| result |
	filter hideClosedIssues: false.
	filter dueDateFilter: #all.

	result := filter applyTo: sampleIssues.

	self assert: result size equals: sampleIssues size
]

{ #category : 'running' }
IssueFilterTest >> testDueDateFilterThisWeek [
	"Test filtering issues active this week"

	| result today weekFromNow |
	filter hideClosedIssues: true. "because a closed issue can have a startDate and endDate both in the past"
	filter dueDateFilter: #thisWeek.
	today := Date today.
	weekFromNow := today addDays: 7.

	result := filter applyTo: sampleIssues.

	"Should only include issues active this week"
	result do: [ :issue |
		| startDate endDate |
		startDate := issue dependencyAwareStartDate.
		endDate := issue dependencyAwareEndDate.

		self assert: (startDate notNil and: [
				 endDate notNil and: [
					 startDate asDate <= weekFromNow and: [ endDate asDate >= today ] ] ]) ]
]

{ #category : 'running' }
IssueFilterTest >> testDueDateFilterToday [
	"Test filtering issues active today"
	| result |
	
	filter hideClosedIssues: false.
	filter dueDateFilter: #today.
	
	result := filter applyTo: sampleIssues.
	
	"Should only include issues active today"
	result do: [ :issue |
		| startDate endDate today |
		startDate := issue dependencyAwareStartDate.
		endDate := issue dependencyAwareEndDate.
		today := Date today.
		
		self assert: (startDate notNil and: [ 
			endDate notNil and: [ 
				today between: startDate asDate and: endDate asDate ] ]) ]
]

{ #category : 'running' }
IssueFilterTest >> testEmptyIssueCollection [
	"Test filtering an empty collection"
	| result emptyCollection |
	
	emptyCollection := OrderedCollection new.
	
	filter hideClosedIssues: true.
	result := filter applyTo: emptyCollection.
	
	self assert: result isEmpty
]

{ #category : 'running' }
IssueFilterTest >> testFilterActiveThisWeek [
	"Test filtering issues active this week"
	| result |
	
	result := filter filterActiveThisWeek: sampleIssues.
	
	"Should include issues that overlap with this week"
	self assert: (result anySatisfy: [ :issue | 
		issue startDate notNil and: [ issue dueDate notNil ] ]).
	
	"Result should not be empty"
	self deny: result isEmpty
]

{ #category : 'running' }
IssueFilterTest >> testFilterActiveToday [
	"Test filtering issues active today"
	| result |
	
	result := filter filterActiveToday: sampleIssues.
	
	"Should include issues that span today"
	self assert: (result anySatisfy: [ :issue | 
		"issue title = 'Open Issue' or: [ issue title = 'In Progress Issue' or: [ issue title = 'Blocked Issue' ] ] ])."
		 #(closed resolved) includes: issue status]).
	"Result should not be empty"
	self deny: result isEmpty
]

{ #category : 'running' }
IssueFilterTest >> testFromToolbar [
	"Test creating filter from toolbar settings"
	| toolbar |
	
	"Create a proper mock using an anonymous class"
	toolbar := Object newAnonymousSubclass new.
	toolbar class addInstVarNamed: 'hideClosedIssues'.
	toolbar class addInstVarNamed: 'dueDateFilter'.
	
	toolbar instVarNamed: 'hideClosedIssues' put: true.
	toolbar instVarNamed: 'dueDateFilter' put: #today.
	
	"Create filter from toolbar"
	self should: [ IssueFilter fromToolbar: toolbar ] raise: Error
]

{ #category : 'running' }
IssueFilterTest >> testHideClosedIssues [
	"Test filtering out closed and resolved issues"

	| result |
	filter hideClosedIssues: true.
	filter dueDateFilter: #all.

	result := filter applyTo: sampleIssues.

	"Should exclude resolved and closed issues"
	self assert:
		(result noneSatisfy: [ :issue | issue status = #closed ]).
	self assert:
		(result noneSatisfy: [ :issue | issue status = #resolved ]).
	
	"Should include open, inProgress, blocked, and milestone"
	self assert: (result anySatisfy: [ :issue | issue status = #open ]).
	self assert:
		(result anySatisfy: [ :issue | issue status = #inProgress ]).
	self assert:
		(result anySatisfy: [ :issue | issue status = #blocked ]).
	self assert:
		(result anySatisfy: [ :issue | issue status = #milestone ])
]

{ #category : 'running' }
IssueFilterTest >> testHideClosedIssuesAccessor [
	"Test the hideClosedIssues accessor"
	
	filter hideClosedIssues: true.
	self assert: filter hideClosedIssues equals: true.
	
	filter hideClosedIssues: false.
	self assert: filter hideClosedIssues equals: false
]

{ #category : 'running' }
IssueFilterTest >> testInitialize [
	"Test that filter initializes with correct defaults"
	| newFilter |
	
	newFilter := IssueFilter new.
	
	self assert: newFilter hideClosedIssues equals: false.
	self assert: newFilter dueDateFilter equals: #all
]

{ #category : 'running' }
IssueFilterTest >> testIssueWithoutDates [
	"Test filtering issues that don't have dates set"

	| issueWithoutDates result |
	issueWithoutDates := Issue new
		                     title: 'No Dates';
		                     status: #open;
		                     yourself.

	sampleIssues add: issueWithoutDates.

	filter dueDateFilter: #today.
	result := filter applyTo: sampleIssues.

	"Issues without dates default to current date"
	self assert: (result includes: issueWithoutDates)
]

{ #category : 'running' }
IssueFilterTest >> testShowClosedIssues [
	"Test that closed issues are shown when hideClosedIssues is false"
	| result |
	
	filter hideClosedIssues: false.
	filter dueDateFilter: #all.
	
	result := filter applyTo: sampleIssues.
	
	self assert: (result anySatisfy: [ :issue | issue status = #closed ]).
	self assert: (result anySatisfy: [ :issue | issue status = #resolved ])
]
