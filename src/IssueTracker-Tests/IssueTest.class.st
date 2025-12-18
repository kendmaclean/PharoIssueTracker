Class {
	#name : 'IssueTest',
	#superclass : 'TestCase',
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
IssueTest >> testAddDependency [
	"Test adding a dependency to an issue"
	| issue1 issue2 |
	issue1 := Issue new title: 'Issue 1'.
	issue2 := Issue new title: 'Issue 2'.
	
	issue1 addDependency: issue2.
	
	self assert: (issue1 dependencies includes: issue2).
	self assert: issue1 dependencies size equals: 1.
]

{ #category : 'tests' }
IssueTest >> testCannotAddDuplicateDependency [
	"Test that duplicate dependencies are prevented"
	| issue1 issue2 |
	issue1 := Issue new title: 'Issue 1'.
	issue2 := Issue new title: 'Issue 2'.
	
	issue1 addDependency: issue2.
	self should: [ issue1 addDependency: issue2 ] raise: Error.
]

{ #category : 'tests' }
IssueTest >> testCannotAddSelfAsDependency [
	"Test that an issue cannot depend on itself"
	| issue |
	issue := Issue new title: 'Issue 1'.
	
	self should: [ issue addDependency: issue ] raise: Error.
]

{ #category : 'tests' }
IssueTest >> testCircularDependencyDetection [
	"Test that circular dependencies are detected and prevented"
	| issue1 issue2 issue3 |
	issue1 := Issue new title: 'Issue 1'.
	issue2 := Issue new title: 'Issue 2'.
	issue3 := Issue new title: 'Issue 3'.
	
	issue1 addDependency: issue2.
	issue2 addDependency: issue3.
	
	"Try to create a cycle: issue3 -> issue1"
	self should: [ issue3 addDependency: issue1 ] raise: Error.
]

{ #category : 'tests' }
IssueTest >> testComplexDependencyChain [
	"Test a complex chain of dependencies"
	| issue1 issue2 issue3 issue4 |
	issue1 := Issue new title: 'Foundation'; startDate: Date today; duration: 2.
	issue2 := Issue new title: 'Build'; startDate: Date today; duration: 3.
	issue3 := Issue new title: 'Test'; startDate: Date today; duration: 2.
	issue4 := Issue new title: 'Deploy'; startDate: Date today; duration: 1.
	
	issue2 addDependency: issue1.  "Build depends on Foundation"
	issue3 addDependency: issue2.  "Test depends on Build"
	issue4 addDependency: issue3.  "Deploy depends on Test"
	
	self assert: issue4 dependencies size equals: 1.
	self assert: issue2 dependencyAwareStartDate >= issue1 dependencyAwareEndDate.
	self assert: issue3 dependencyAwareStartDate >= issue2 dependencyAwareEndDate.
	self assert: issue4 dependencyAwareStartDate >= issue3 dependencyAwareEndDate.
]

{ #category : 'tests' }
IssueTest >> testComputedDueDateCalculatedFromStartDate [
	"Test that computedDueDate calculates forward from startDate when no dueDate"
	| issue startDate |
	issue := Issue new.
	startDate := Date today.
	
	issue startDate: startDate.
	issue duration: 5.
	
	self assert: issue computedDueDate equals: (startDate addDays: 5).
]

{ #category : 'tests' }
IssueTest >> testComputedDueDateIsNilWhenNoDates [
	"Test that computedDueDate returns nil when no dates are set"
	| issue |
	issue := Issue new.
	
	self assert: issue computedDueDate isNil.
]

{ #category : 'tests' }
IssueTest >> testComputedDueDateWhenSet [
	"Test that computedDueDate returns the set dueDate"
	| issue date |
	issue := Issue new.
	date := Date today addDays: 7.
	
	issue dueDate: date.
	self assert: issue computedDueDate equals: date asDate.
]

{ #category : 'tests' }
IssueTest >> testComputedDurationCalculatedFromDates [
	"Test that computedDuration calculates from start and due dates"
	| issue startDate dueDate |
	issue := Issue new.
	startDate := Date today.
	dueDate := Date today addDays: 7.
	
	issue startDate: startDate.
	issue dueDate: dueDate.
	
	self assert: issue computedDuration equals: 7.
]

{ #category : 'tests' }
IssueTest >> testComputedDurationDefaultsToOne [
	"Test that computedDuration defaults to 1 when no duration or dates set"
	| issue |
	issue := Issue new.
	
	self assert: issue computedDuration equals: 1.
]

{ #category : 'tests' }
IssueTest >> testComputedDurationWhenSet [
	"Test that computedDuration returns the set duration"
	| issue |
	issue := Issue new.
	
	issue duration: 10.
	self assert: issue computedDuration equals: 10.
]

{ #category : 'tests' }
IssueTest >> testComputedStartDateCalculatedFromDueDate [
	"Test that computedStartDate calculates backward from dueDate when no startDate"
	| issue dueDate |
	issue := Issue new.
	dueDate := Date today addDays: 10.
	
	issue dueDate: dueDate.
	issue duration: 5.
	
	self assert: issue computedStartDate equals: (dueDate subtractDays: 5).
]

{ #category : 'tests' }
IssueTest >> testComputedStartDateDefaultsToCreatedAt [
	"Test that computedStartDate defaults to createdAt when no dates set"
	| issue |
	issue := Issue new.
	
	self assert: issue computedStartDate equals: issue createdAt asDate.
]

{ #category : 'tests' }
IssueTest >> testComputedStartDateWhenSet [
	"Test that computedStartDate returns the set startDate"
	| issue date |
	issue := Issue new.
	date := Date today.
	
	issue startDate: date.
	self assert: issue computedStartDate equals: date asDate.
]

{ #category : 'tests' }
IssueTest >> testDependencyAwareEndDate [
	"Test that dependencyAwareEndDate calculates correctly"
	| issue |
	issue := Issue new.
	issue startDate: Date today.
	issue duration: 5.
	
	self assert: issue dependencyAwareEndDate notNil.
]

{ #category : 'tests' }
IssueTest >> testDependencyAwareEndDateWithFractionalDuration [
	"Test that fractional durations work correctly with dependency-aware dates"

	| issue |
	issue := Issue new.
	issue startDate: Date today.
	issue duration: 0.5.

	"End date should be calculated correctly with fractional days"
	self assert: issue dependencyAwareEndDate notNil.
	"The end date should be a DateAndTime, not just a Date"
	self assert: (issue dependencyAwareEndDate isKindOf: DateAndTime)
]

{ #category : 'tests' }
IssueTest >> testDependencyAwareStartDateWithDependencies [
	"Test that dependencyAwareStartDate considers dependency end dates"
	| issue1 issue2 |
	issue1 := Issue new.
	issue1 startDate: Date today.
	issue1 duration: 5.
	
	issue2 := Issue new.
	issue2 startDate: Date today.
	issue2 duration: 3.
	
	issue2 addDependency: issue1.
	
	"issue2 should start after issue1 ends"
	self assert: issue2 dependencyAwareStartDate >= issue1 dependencyAwareEndDate.
]

{ #category : 'tests' }
IssueTest >> testDependencyAwareStartDateWithNoDependencies [
	"Test that dependencyAwareStartDate returns computed date when no dependencies"
	| issue startDate |
	issue := Issue new.
	startDate := Date today.
	
	issue startDate: startDate.
	issue duration: 5.
	
	self assert: issue dependencyAwareStartDate asDate equals: startDate.
]

{ #category : 'tests' }
IssueTest >> testDescriptionAccessors [
	"Test description getter and setter"
	| issue |
	issue := Issue new.
	
	issue description: 'This is a test description'.
	self assert: issue description equals: 'This is a test description'.
]

{ #category : 'tests' }
IssueTest >> testDisplayString [
	"Test that displayString generates appropriate text"
	| issue displayText |
	issue := Issue new.
	issue title: 'Test Issue'.
	issue priority: #high.
	issue status: #open.
	issue dueDate: Date today.
	
	displayText := issue displayString.
	
	self assert: (displayText asString includesSubstring: 'Test Issue').
	self assert: (displayText asString includesSubstring: 'high').
	self assert: (displayText asString includesSubstring: 'open').
]

{ #category : 'tests' }
IssueTest >> testDueDateAccessors [
	"Test dueDate getter and setter"
	| issue date |
	issue := Issue new.
	date := Date today addDays: 7.
	
	issue dueDate: date.
	self assert: issue dueDate equals: date.
]

{ #category : 'tests' }
IssueTest >> testDurationAccessors [
	"Test duration getter and setter"
	| issue |
	issue := Issue new.
	
	issue duration: 5.
	self assert: issue duration equals: 5.
]

{ #category : 'tests' }
IssueTest >> testEmptyTitle [
	"Test issue with empty title"
	| issue |
	issue := Issue new.
	
	issue title: ''.
	self assert: issue title equals: ''.
]

{ #category : 'tests' }
IssueTest >> testFractionalDuration025 [
	"Test handling of 0.25 day duration (6 hours)"
	| issue startDate endDate expectedEnd |
	issue := Issue new.
	startDate := Date today.
	
	issue startDate: startDate.
	issue duration: 0.25.
	
	self assert: issue duration equals: 0.25.
	self assert: issue computedDuration equals: 0.25.
	
	"Verify end date calculation - 0.25 days = 21600 seconds = 6 hours"
	endDate := issue dependencyAwareEndDate.
	expectedEnd := startDate asDateAndTime + (Duration days: 0 hours: 0 minutes: 0 seconds: (0.25 * 86400) rounded).
	self assert: endDate equals: expectedEnd.
]

{ #category : 'tests' }
IssueTest >> testFractionalDuration050 [
	"Test handling of 0.5 day duration (12 hours)"
	| issue startDate endDate expectedEnd |
	issue := Issue new.
	startDate := Date today.
	
	issue startDate: startDate.
	issue duration: 0.5.
	
	self assert: issue duration equals: 0.5.
	self assert: issue computedDuration equals: 0.5.
	
	"Verify end date calculation - 0.5 days = 43200 seconds = 12 hours"
	endDate := issue dependencyAwareEndDate.
	expectedEnd := startDate asDateAndTime + (Duration days: 0 hours: 0 minutes: 0 seconds: (0.5 * 86400) rounded).
	self assert: endDate equals: expectedEnd.
]

{ #category : 'tests' }
IssueTest >> testFractionalDuration075 [
	"Test handling of 0.75 day duration (18 hours)"
	| issue startDate endDate expectedEnd |
	issue := Issue new.
	startDate := Date today.
	
	issue startDate: startDate.
	issue duration: 0.75.
	
	self assert: issue duration equals: 0.75.
	self assert: issue computedDuration equals: 0.75.
	
	"Verify end date calculation - 0.75 days = 64800 seconds = 18 hours"
	endDate := issue dependencyAwareEndDate.
	expectedEnd := startDate asDateAndTime + (Duration days: 0 hours: 0 minutes: 0 seconds: (0.75 * 86400) rounded).
	self assert: endDate equals: expectedEnd.
]

{ #category : 'tests' }
IssueTest >> testFractionalDurationWithDependencies [
	"Test that fractional durations work correctly in dependency chains"
	| issue1 issue2 |
	issue1 := Issue new.
	issue1 startDate: Date today.
	issue1 duration: 0.25.
	
	issue2 := Issue new.
	issue2 startDate: Date today.
	issue2 duration: 0.75.
	
	issue2 addDependency: issue1.
	
	"issue2 should start after issue1 ends (0.25 days later)"
	self assert: issue2 dependencyAwareStartDate >= issue1 dependencyAwareEndDate.
]

{ #category : 'tests' }
IssueTest >> testHasDependencies [
	"Test hasDependencies method"
	| issue1 issue2 |
	issue1 := Issue new title: 'Issue 1'.
	issue2 := Issue new title: 'Issue 2'.
	
	self deny: issue1 hasDependencies.
	
	issue1 addDependency: issue2.
	self assert: issue1 hasDependencies.
]

{ #category : 'tests' }
IssueTest >> testInitialize [
	"Test that a new Issue initializes with correct default values"
	| issue |
	issue := Issue new.
	
	self assert: issue id notNil.
	self assert: issue createdAt notNil.
	self assert: issue status equals: #open.
	self assert: issue priority equals: #medium.
	self assert: issue dependencies isEmpty.
	self deny: issue isMilestone.
]

{ #category : 'tests' }
IssueTest >> testIsMilestone [
	"Test isMilestone getter and setter"
	| issue |
	issue := Issue new.
	
	self deny: issue isMilestone.
	
	issue isMilestone: true.
	self assert: issue isMilestone.
	
	issue isMilestone: false.
	self deny: issue isMilestone.
]

{ #category : 'tests' }
IssueTest >> testIssueWithAllFieldsSet [
	"Test an issue with all possible fields set"
	| issue date |
	issue := Issue new.
	date := Date today.
	
	issue title: 'Complete Issue'.
	issue description: 'A fully specified issue for testing'.
	issue status: #inProgress.
	issue priority: #critical.
	issue startDate: date.
	issue duration: 5.
	issue dueDate: (date addDays: 5).
	issue isMilestone: false.
	
	self assert: issue title equals: 'Complete Issue'.
	self assert: issue description equals: 'A fully specified issue for testing'.
	self assert: issue status equals: #inProgress.
	self assert: issue priority equals: #critical.
	self assert: issue startDate equals: date.
	self assert: issue duration equals: 5.
	self assert: issue dueDate equals: (date addDays: 5).
	self deny: issue isMilestone.
]

{ #category : 'tests' }
IssueTest >> testMilestoneIssue [
	"Test an issue marked as a milestone"
	| issue |
	issue := Issue new.
	issue title: 'Version 1.0 Release'.
	issue status: #milestone.
	issue isMilestone: true.
	
	self assert: issue isMilestone.
	self assert: issue status equals: #milestone.
]

{ #category : 'tests' }
IssueTest >> testMixedIntegerAndFractionalDurations [
	"Test a dependency chain with mixed integer and fractional durations"
	| issue1 issue2 issue3 |
	issue1 := Issue new title: 'Quick task'; startDate: Date today; duration: 0.5.
	issue2 := Issue new title: 'Medium task'; startDate: Date today; duration: 2.
	issue3 := Issue new title: 'Short task'; startDate: Date today; duration: 0.25.
	
	issue2 addDependency: issue1.
	issue3 addDependency: issue2.
	
	self assert: issue1 duration equals: 0.5.
	self assert: issue2 duration equals: 2.
	self assert: issue3 duration equals: 0.25.
	self assert: issue2 dependencyAwareStartDate >= issue1 dependencyAwareEndDate.
	self assert: issue3 dependencyAwareStartDate >= issue2 dependencyAwareEndDate.
]

{ #category : 'tests' }
IssueTest >> testMultipleDependencies [
	"Test that multiple dependencies are handled correctly"
	| issue1 issue2 issue3 |
	issue1 := Issue new.
	issue1 startDate: Date today.
	issue1 duration: 3.
	
	issue2 := Issue new.
	issue2 startDate: (Date today addDays: 1).
	issue2 duration: 4.
	
	issue3 := Issue new.
	issue3 startDate: Date today.
	issue3 duration: 2.
	
	issue3 addDependency: issue1.
	issue3 addDependency: issue2.
	
	"issue3 should start after the latest dependency ends"
	self assert: issue3 dependencyAwareStartDate >= issue1 dependencyAwareEndDate.
	self assert: issue3 dependencyAwareStartDate >= issue2 dependencyAwareEndDate.
]

{ #category : 'tests' }
IssueTest >> testNegativeDuration [
	"Test handling of negative duration (edge case)"
	| issue |
	issue := Issue new.
	
	"Setting negative duration should be allowed but may not make logical sense"
	issue duration: -5.
	self assert: issue duration equals: -5.
]

{ #category : 'tests' }
IssueTest >> testNilDates [
	"Test handling of nil dates"
	| issue |
	issue := Issue new.
	
	self assert: issue startDate isNil.
	self assert: issue dueDate isNil.
	self assert: issue duration isNil.
]

{ #category : 'tests' }
IssueTest >> testNilDescription [
	"Test that nil description is handled correctly"
	| issue |
	issue := Issue new.
	
	self assert: issue description isNil.
]

{ #category : 'tests' }
IssueTest >> testPriorityAccessors [
	"Test priority getter and setter"
	| issue |
	issue := Issue new.
	
	issue priority: #high.
	self assert: issue priority equals: #high.
	
	issue priority: #low.
	self assert: issue priority equals: #low.
]

{ #category : 'tests' }
IssueTest >> testRemoveDependency [
	"Test removing a dependency from an issue"
	| issue1 issue2 |
	issue1 := Issue new title: 'Issue 1'.
	issue2 := Issue new title: 'Issue 2'.
	
	issue1 addDependency: issue2.
	issue1 removeDependency: issue2.
	
	self assert: issue1 dependencies isEmpty.
]

{ #category : 'tests' }
IssueTest >> testStartDateAccessors [
	"Test startDate getter and setter"
	| issue date |
	issue := Issue new.
	date := Date today.
	
	issue startDate: date.
	self assert: issue startDate equals: date.
]

{ #category : 'tests' }
IssueTest >> testStatusAccessors [
	"Test status getter and setter"
	| issue |
	issue := Issue new.
	
	issue status: #inProgress.
	self assert: issue status equals: #inProgress.
	
	issue status: #resolved.
	self assert: issue status equals: #resolved.
]

{ #category : 'tests' }
IssueTest >> testTitleAccessors [
	"Test title getter and setter"
	| issue |
	issue := Issue new.
	
	issue title: 'Test Issue'.
	self assert: issue title equals: 'Test Issue'.
]

{ #category : 'tests' }
IssueTest >> testUniqueIds [
	"Test that each issue gets a unique ID"
	| issue1 issue2 |
	issue1 := Issue new.
	issue2 := Issue new.
	
	"self deny: issue1 id = issue2 id."
	self deny: issue1 id equals: issue2 id.
]

{ #category : 'tests' }
IssueTest >> testVerySmallFractionalDuration [
	"Test handling of very small fractional durations"
	| issue startDate endDate expectedEnd |
	issue := Issue new.
	startDate := Date today.
	issue startDate: startDate.
	issue duration: 0.1.
	
	self assert: issue duration equals: 0.1.
	self assert: issue computedDuration equals: 0.1.
	
	"Should calculate end date correctly - 0.1 days = 8640 seconds = 2.4 hours"
	endDate := issue dependencyAwareEndDate.
	self assert: endDate notNil.
	
	"Verify the end date is approximately correct (within same day or next day)"
	expectedEnd := startDate asDateAndTime + (Duration days: 0 hours: 0 minutes: 0 seconds: (0.1 * 86400) rounded).
	self assert: endDate equals: expectedEnd.
]

{ #category : 'tests' }
IssueTest >> testWouldCreateCircularDependency [
	"Test the wouldCreateCircularDependency method"
	| issue1 issue2 issue3 |
	issue1 := Issue new title: 'Issue 1'.
	issue2 := Issue new title: 'Issue 2'.
	issue3 := Issue new title: 'Issue 3'.
	
	issue1 addDependency: issue2.
	issue2 addDependency: issue3.
	
	self assert: (issue3 wouldCreateCircularDependency: issue1).
	self deny: (issue3 wouldCreateCircularDependency: issue2) not.
]

{ #category : 'tests' }
IssueTest >> testZeroDuration [
	"Test handling of zero duration"
	| issue startDate |
	issue := Issue new.
	startDate := Date today.
	
	issue startDate: startDate.
	issue duration: 0.
	
	self assert: issue duration equals: 0.
]
