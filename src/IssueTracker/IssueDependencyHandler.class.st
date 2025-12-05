Class {
	#name : 'IssueDependencyHandler',
	#superclass : 'Object',
	#instVars : [
		'issue'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'accessing' }
IssueDependencyHandler >> addDependency: aTargetIssue [
	(self canAddDependency: aTargetIssue)
		ifFalse: [ self error: 'Cannot add dependency: Invalid or circular dependency detected' ].
	
	issue dependencies add: aTargetIssue
]

{ #category : 'accessing' }
IssueDependencyHandler >> availableDependenciesIn: aCollection [
	"Returns all issues from aCollection that are valid candidates for dependencies"
	^ aCollection select: [ :candidate | self canAddDependency: candidate ]
]

{ #category : 'accessing' }
IssueDependencyHandler >> canAddDependency: aTargetIssue [
	"Checks if aTargetIssue can be added as a dependency.
	 Enforces: uniqueness, non-reflexivity, and acyclic graph."
	
	"Cannot depend on self"
	issue = aTargetIssue ifTrue: [ ^ false ].
	
	"Cannot add duplicate dependency"
	(issue dependencies includes: aTargetIssue) ifTrue: [ ^ false ].
	
	"Check for circular dependency"
	^ (self detectsCycleWith: aTargetIssue) not
]

{ #category : 'accessing' }
IssueDependencyHandler >> checkRecursively: currentIssue visited: visitedSet [
	"Recursive Depth-First Search"
	
	"If we encounter the original issue, a cycle exists"
	currentIssue = issue ifTrue: [ ^ true ].
	
	"Avoid infinite recursion on existing cycles or shared branches"
	(visitedSet includes: currentIssue) ifTrue: [ ^ false ].
	visitedSet add: currentIssue.
	
	"Recurse down the dependencies"
	currentIssue dependencies do: [ :dep |
		(self checkRecursively: dep visited: visitedSet) ifTrue: [ ^ true ] ].
		
	^ false
]

{ #category : 'accessing' }
IssueDependencyHandler >> detectsCycleWith: aTargetIssue [
	"Check if adding aTargetIssue as a dependency would create a cycle.
	 This implies checking if aTargetIssue (or its dependencies) already depends on 'issue'."
	^ self checkRecursively: aTargetIssue visited: Set new
]

{ #category : 'accessing' }
IssueDependencyHandler >> issue: anIssue [
	issue := anIssue
]

{ #category : 'accessing' }
IssueDependencyHandler >> removeDependency: aTargetIssue [
	issue dependencies remove: aTargetIssue ifAbsent: []
]

{ #category : 'accessing' }
IssueDependencyHandler >> resolveEndDate [
	| adjStart |
	adjStart := self resolveStartDate.
	adjStart ifNil: [ ^ nil ].
	^ adjStart asDate addDays: issue computedDuration
]

{ #category : 'accessing' }
IssueDependencyHandler >> resolveStartDate [
	"Calculates start date based on the latest end date of all dependencies"
	| baseStart latestDependencyEnd |
	
	baseStart := issue computedStartDate.
	issue dependencies ifEmpty: [ ^ baseStart ].
	
	"Find the latest end date among dependencies (using the handler recursively if needed, 
     or relying on the issue's polymorphically compliant interface)"
	latestDependencyEnd := issue dependencies 
		collect: [ :dep | dep dependencyAwareEndDate ]
		thenSelect: [ :date | date notNil ].
		
	latestDependencyEnd ifEmpty: [ ^ baseStart ].
	latestDependencyEnd := latestDependencyEnd max.
	
	^ baseStart 
		ifNil: [ latestDependencyEnd ]
		ifNotNil: [ baseStart max: latestDependencyEnd ]
]
