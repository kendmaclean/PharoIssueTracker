Class {
	#name : 'IssueDependencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler',
		'issue1',
		'issue2',
		'issue3',
		'issue4'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'accessing' }
IssueDependencyHandlerTest class >> packageNamesUnderTest [
	^ #('IssueTracker')
]

{ #category : 'running' }
IssueDependencyHandlerTest >> setUp [
	"Set up test fixtures"
	super setUp.
	
	"Create test issues"
	issue1 := Issue new
		title: 'Issue 1';
		status: #open;
		priority: #medium;
		startDate: Date today;
		duration: 5;
		yourself.
		
	issue2 := Issue new
		title: 'Issue 2';
		status: #open;
		priority: #medium;
		startDate: Date today;
		duration: 3;
		yourself.
		
	issue3 := Issue new
		title: 'Issue 3';
		status: #open;
		priority: #medium;
		startDate: Date today;
		duration: 4;
		yourself.
		
	issue4 := Issue new
		title: 'Issue 4';
		status: #open;
		priority: #medium;
		startDate: Date today;
		duration: 2;
		yourself.
	
	"Create handler for issue1"
	handler := IssueDependencyHandler new issue: issue1
]

{ #category : 'running' }
IssueDependencyHandlerTest >> tearDown [
	"Clean up after test"
	handler := nil.
	issue1 := nil.
	issue2 := nil.
	issue3 := nil.
	issue4 := nil.
	super tearDown
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testAllowsNonCircularDependencies [
	"Test that non-circular dependencies are allowed"
	
	| handler2 handler3 |
	
	"Create valid DAG: issue1 -> issue2, issue1 -> issue3"
	handler addDependency: issue2.
	handler addDependency: issue3.
	
	"issue2 -> issue4 should also be valid"
	handler2 := IssueDependencyHandler new issue: issue2.
	self assert: (handler2 canAddDependency: issue4).
	
	"issue3 -> issue4 should also be valid"
	handler3 := IssueDependencyHandler new issue: issue3.
	self assert: (handler3 canAddDependency: issue4)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testAvailableDependenciesExcludesCircular [
	"Test that dependencies that would create cycles are excluded"
	
	| available allIssues handler2 |
	
	"Create: issue2 -> issue1"
	handler2 := IssueDependencyHandler new issue: issue2.
	handler2 addDependency: issue1.
	
	"Check available for issue1 (should exclude issue2 as it would create cycle)"
	allIssues := OrderedCollection with: issue1 with: issue2 with: issue3.
	available := handler availableDependenciesIn: allIssues.
	
	self deny: (available includes: issue1).
	self deny: (available includes: issue2).
	self assert: (available includes: issue3)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testAvailableDependenciesExcludesExisting [
	"Test that existing dependencies are excluded from available"
	
	| available allIssues |
	handler addDependency: issue2.
	
	allIssues := OrderedCollection with: issue1 with: issue2 with: issue3 with: issue4.
	available := handler availableDependenciesIn: allIssues.
	
	self deny: (available includes: issue1).
	self deny: (available includes: issue2).
	self assert: (available includes: issue3).
	self assert: (available includes: issue4)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testAvailableDependenciesExcludesSelf [
	"Test that the issue itself is excluded from available dependencies"
	
	| available allIssues |
	allIssues := OrderedCollection with: issue1 with: issue2 with: issue3.
	available := handler availableDependenciesIn: allIssues.
	
	self deny: (available includes: issue1).
	self assert: (available includes: issue2).
	self assert: (available includes: issue3)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testAvailableDependenciesWithEmptyCollection [
	"Test available dependencies with an empty collection"
	
	| available |
	available := handler availableDependenciesIn: OrderedCollection new.
	
	self assert: available isEmpty
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testCanAddValidDependency [
	"Test that a valid dependency can be added"
	
	self assert: (handler canAddDependency: issue2).
	
	handler addDependency: issue2.
	
	self assert: issue1 dependencies size equals: 1.
	self assert: (issue1 dependencies includes: issue2)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testCannotAddDuplicateDependency [
	"Test that the same dependency cannot be added twice"
	
	handler addDependency: issue2.
	
	self deny: (handler canAddDependency: issue2).
	
	self 
		should: [ handler addDependency: issue2 ]
		raise: Error
		description: 'Should not allow duplicate dependencies'
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testCannotAddSelfAsDependency [
	"Test that an issue cannot depend on itself"
	
	self deny: (handler canAddDependency: issue1).
	
	self 
		should: [ handler addDependency: issue1 ]
		raise: Error
		description: 'Should not allow adding self as dependency'
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testChainedDependencies [
	"Test a chain of dependencies: issue1 -> issue2 -> issue3 -> issue4"
	
	| handler2 handler3 handler4 |
	
	"Set up dates"
	issue4 startDate: Date today.
	issue4 duration: 2.
	
	issue3 duration: 3.
	issue2 duration: 4.
	issue1 duration: 5.
	
	"Build chain"
	handler4 := IssueDependencyHandler new issue: issue4.
	
	handler3 := IssueDependencyHandler new issue: issue3.
	handler3 addDependency: issue4.
	
	handler2 := IssueDependencyHandler new issue: issue2.
	handler2 addDependency: issue3.
	
	handler addDependency: issue2.
	
	"Verify start dates propagate through chain"
	self assert: handler3 resolveStartDate >= issue4 dependencyAwareEndDate.
	self assert: handler2 resolveStartDate >= issue3 dependencyAwareEndDate.
	self assert: handler resolveStartDate >= issue2 dependencyAwareEndDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testDependencyWithNilDates [
	"Test behavior when a dependency has nil dates"
	
	| issueWithNilDates handlerNil resolvedDate |
	
	issueWithNilDates := Issue new
		title: 'Issue with nil dates';
		yourself.
	
	"This should not raise an error"
	handlerNil := IssueDependencyHandler new issue: issue1.
	handlerNil addDependency: issueWithNilDates.
	
	resolvedDate := handlerNil resolveStartDate.
	
	"Should fallback to issue's own start date or computed date"
	self assert: resolvedDate notNil
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testDetectsDirectCircularDependency [
	"Test detection of direct circular dependency: A -> B -> A"
	
	| handler2 |
	
	"Add issue2 as dependency of issue1"
	handler addDependency: issue2.
	
	"Try to add issue1 as dependency of issue2 (creates circle)"
	handler2 := IssueDependencyHandler new issue: issue2.
	
	self deny: (handler2 canAddDependency: issue1).
	self assert: (handler2 detectsCycleWith: issue1)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testDetectsIndirectCircularDependency [
	"Test detection of indirect circular dependency: A -> B -> C -> A"
	
	| handler2 handler3 |
	
	"Create chain: issue1 -> issue2 -> issue3"
	handler addDependency: issue2.
	handler2 := IssueDependencyHandler new issue: issue2.
	handler2 addDependency: issue3.
	
	"Try to add issue1 as dependency of issue3 (creates circle)"
	handler3 := IssueDependencyHandler new issue: issue3.
	
	self deny: (handler3 canAddDependency: issue1).
	self assert: (handler3 detectsCycleWith: issue1)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testDetectsLongerCircularDependency [
	"Test detection of longer circular dependency: A -> B -> C -> D -> A"
	
	| handler2 handler3 handler4 |
	
	"Create chain: issue1 -> issue2 -> issue3 -> issue4"
	handler addDependency: issue2.
	handler2 := IssueDependencyHandler new issue: issue2.
	handler2 addDependency: issue3.
	handler3 := IssueDependencyHandler new issue: issue3.
	handler3 addDependency: issue4.
	
	"Try to add issue1 as dependency of issue4 (creates circle)"
	handler4 := IssueDependencyHandler new issue: issue4.
	
	self deny: (handler4 canAddDependency: issue1).
	self assert: (handler4 detectsCycleWith: issue1)
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testDiamondDependencyPattern [
	"Test diamond pattern: issue1 depends on both issue2 and issue3, both depend on issue4"
	
	| handler2 handler3 |
	
	issue4 startDate: Date today.
	issue4 duration: 2.
	
	issue2 duration: 3.
	issue3 duration: 5.  "longer path"
	issue1 duration: 2.
	
	"Build diamond"
	handler2 := IssueDependencyHandler new issue: issue2.
	handler2 addDependency: issue4.
	
	handler3 := IssueDependencyHandler new issue: issue3.
	handler3 addDependency: issue4.
	
	handler addDependency: issue2.
	handler addDependency: issue3.
	
	"issue1 should start after the longest path (through issue3)"
	self assert: handler resolveStartDate >= issue3 dependencyAwareEndDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testMultipleIndependentChains [
	"Test that an issue can have multiple independent dependency chains"
	
	| issue5 issue6 handler5 handler6 |
	
	"Create two independent chains"
	issue5 := Issue new title: 'Issue 5'; startDate: Date today; duration: 3; yourself.
	issue6 := Issue new title: 'Issue 6'; startDate: (Date today addDays: 5); duration: 4; yourself.
	
	"Chain 1: issue2 -> issue3"
	issue3 startDate: Date today.
	issue3 duration: 2.
	
	handler5 := IssueDependencyHandler new issue: issue2.
	handler5 addDependency: issue3.
	
	"Chain 2: issue5 -> issue6"
	handler6 := IssueDependencyHandler new issue: issue5.
	handler6 addDependency: issue6.
	
	"issue1 depends on both chains"
	handler addDependency: issue2.
	handler addDependency: issue5.
	
	"Should start after the latest of both chains"
	self assert: handler resolveStartDate >= issue2 dependencyAwareEndDate.
	self assert: handler resolveStartDate >= issue5 dependencyAwareEndDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testRemoveDependency [
	"Test removing a dependency"
	
	handler addDependency: issue2.
	self assert: issue1 dependencies size equals: 1.
	
	handler removeDependency: issue2.
	self assert: issue1 dependencies isEmpty
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testRemoveNonExistentDependency [
	"Test that removing a non-existent dependency doesn't cause errors"
	
	self assert: issue1 dependencies isEmpty.
	
	handler removeDependency: issue2.
	
	self assert: issue1 dependencies isEmpty
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testResolveEndDateWithDependencies [
	"Test that end date is correctly calculated from adjusted start date"
	
	| resolvedEndDate |
	
	issue2 startDate: Date today.
	issue2 duration: 3.
	
	issue1 duration: 5.
	handler addDependency: issue2.
	
	resolvedEndDate := handler resolveEndDate.
	
	"End date should be start date + duration"
	self assert: resolvedEndDate notNil.
	self assert: resolvedEndDate >= issue2 dependencyAwareEndDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testResolveEndDateWithFractionalDuration [
	"Test that fractional durations are handled correctly"
	
	| resolvedEndDate startDate |
	
	issue1 startDate: Date today.
	issue1 duration: 2.5.
	
	resolvedEndDate := handler resolveEndDate.
	startDate := handler resolveStartDate.
	
	self assert: resolvedEndDate notNil.
	"Duration of 2.5 days should be handled"
	self assert: (resolvedEndDate asDate julianDayNumber - startDate asDate julianDayNumber) >= 2
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testResolveEndDateWithNoDependencies [
	"Test end date resolution with no dependencies"
	
	| resolvedEndDate expectedEndDate |
	
	issue1 startDate: Date today.
	issue1 duration: 5.
	
	resolvedEndDate := handler resolveEndDate.
	expectedEndDate := issue1 computedStartDate asDateAndTime 
		+ (Duration days: 0 hours: 0 minutes: 0 seconds: (5 * 86400) rounded).
	
	self assert: resolvedEndDate asDate equals: expectedEndDate asDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testResolveStartDateWithMultipleDependencies [
	"Test start date resolution with multiple dependencies - should use latest end date"
	
	| resolvedDate |
	
	"Set up dependencies with different end dates"
	issue2 startDate: Date today.
	issue2 duration: 3.  "ends day 3"
	
	issue3 startDate: Date today.
	issue3 duration: 7.  "ends day 7 - latest"
	
	issue4 startDate: Date today.
	issue4 duration: 2.  "ends day 2"
	
	"Add all as dependencies"
	handler addDependency: issue2.
	handler addDependency: issue3.
	handler addDependency: issue4.
	
	"Should start after the latest dependency (issue3)"
	resolvedDate := handler resolveStartDate.
	
	self assert: resolvedDate >= issue3 dependencyAwareEndDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testResolveStartDateWithNoDependencies [
	"Test that start date resolution returns the issue's own start date when no dependencies"
	
	| resolvedDate |
	resolvedDate := handler resolveStartDate.
	
	self assert: resolvedDate equals: issue1 computedStartDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testResolveStartDateWithSingleDependency [
	"Test start date resolution with one dependency"
	
	| resolvedDate expectedDate |
	
	"issue2 ends 3 days from today"
	issue2 startDate: Date today.
	issue2 duration: 3.
	
	"Add issue2 as dependency"
	handler addDependency: issue2.
	
	"issue1 should start after issue2 ends"
	resolvedDate := handler resolveStartDate.
	expectedDate := issue2 dependencyAwareEndDate.
	
	self assert: resolvedDate >= expectedDate
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testVeryLargeDuration [
	"Test handling of issues with very large durations"
	| resolvedEnd |
	
	issue1 duration: 365.  "One year"
	
	resolvedEnd := handler resolveEndDate.
	
	self assert: resolvedEnd notNil.
	"Should be roughly a year from start"
	self assert: (resolvedEnd asDate julianDayNumber - handler resolveStartDate asDate julianDayNumber) >= 360
]

{ #category : 'running' }
IssueDependencyHandlerTest >> testZeroDurationIssue [
	"Test handling of issues with zero or very small duration"
	
	| handler2 |
	
	issue2 startDate: Date today.
	issue2 duration: 0.
	
	handler2 := IssueDependencyHandler new issue: issue2.
	
	self assert: handler2 resolveStartDate notNil.
	self assert: handler2 resolveEndDate notNil
]
