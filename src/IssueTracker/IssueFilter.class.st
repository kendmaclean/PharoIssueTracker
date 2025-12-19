Class {
	#name : 'IssueFilter',
	#superclass : 'Object',
	#instVars : [
		'hideClosedIssues',
		'dueDateFilter'
	],
	#category : 'IssueTracker-Issue',
	#package : 'IssueTracker',
	#tag : 'Issue'
}

{ #category : 'instance creation' }
IssueFilter class >> fromToolbar: aToolbar [
	"Create and configure a filter from toolbar settings"
	
	^ self new fromToolbar: aToolbar
]

{ #category : 'instance creation' }
IssueFilter class >> new [
	^ super new initialize
]

{ #category : 'initialization' }
IssueFilter >> applyClosedFilter: issues [
	"Filter out closed issues if hideClosedIssues is true"

	hideClosedIssues ifFalse: [ ^ issues ].

	"^ issues reject: [ :issue | issue status = #closed ]"
	^ issues reject: [ :issue | 
		"reject issues whose status is in this set"
	    #(closed resolved) includes: issue status ]
]

{ #category : 'initialization' }
IssueFilter >> applyDueDateFilter: issues [
	"Apply due date filter based on dueDateFilter setting"

	dueDateFilter ifNil: [ ^ issues ].

	dueDateFilter = #today ifTrue: [ ^ self filterActiveToday: issues ].
	dueDateFilter = #week ifTrue: [ ^ self filterActiveThisWeek: issues ].
	dueDateFilter = #all ifTrue: [ ^ issues ].
	
	^ issues
]

{ #category : 'initialization' }
IssueFilter >> applyTo: issues [
	"Apply all filters to the given collection of issues"
	| filteredIssues |
	
	filteredIssues := issues.
	
	"Apply closed filter"
	filteredIssues := self applyClosedFilter: filteredIssues.
	
	"Apply due date filter"
	filteredIssues := self applyDueDateFilter: filteredIssues.
	
	^ filteredIssues
]

{ #category : 'initialization' }
IssueFilter >> dueDateFilter [
	^ dueDateFilter
]

{ #category : 'initialization' }
IssueFilter >> dueDateFilter: aSymbol [
	"Set the due date filter: nil (none), #today, #week"
	dueDateFilter := aSymbol
]

{ #category : 'initialization' }
IssueFilter >> filterActiveThisWeek: issues [
	"Return issues that are active this week"
	| today weekFromNow |
	
	today := Date today.
	weekFromNow := today addDays: 7.
	
	^ issues select: [ :issue |
		| startDate endDate |
		startDate := issue dependencyAwareStartDate.
		endDate := issue dependencyAwareEndDate.
		
		startDate notNil and: [ endDate notNil and: [
			"Issue is active this week if it overlaps with the week period"
			(startDate asDate <= weekFromNow) and: [ endDate asDate >= today ] ] ] ]
]

{ #category : 'initialization' }
IssueFilter >> filterActiveToday: issues [
	"Return issues that are active today"
	| today |
	
	today := Date today.
	
	^ issues select: [ :issue |
		| startDate endDate |
		startDate := issue dependencyAwareStartDate.
		endDate := issue dependencyAwareEndDate.
		
		startDate notNil and: [ endDate notNil and: [
			"Issue is active today if today falls between start and end dates"
			today between: startDate asDate and: endDate asDate ] ] ]
]

{ #category : 'initialization' }
IssueFilter >> fromToolbar: aToolbar [
	"Configure filter from toolbar settings"
	
	self hideClosedIssues: aToolbar hideClosedIssues.
	self dueDateFilter: aToolbar dueDateFilter.
	
	^ self
]

{ #category : 'initialization' }
IssueFilter >> hideClosedIssues [
	^ hideClosedIssues
]

{ #category : 'initialization' }
IssueFilter >> hideClosedIssues: aBoolean [
	hideClosedIssues := aBoolean
]

{ #category : 'initialization' }
IssueFilter >> initialize [

	super initialize.
	hideClosedIssues := false.
	dueDateFilter := #all
]
