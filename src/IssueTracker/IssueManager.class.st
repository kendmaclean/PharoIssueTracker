Class {
	#name : 'IssueManager',
	#superclass : 'Object',
	#instVars : [
		'repository'
	],
	#classInstVars : [
		'default'
	],
	#category : 'IssueTracker-Issue',
	#package : 'IssueTracker',
	#tag : 'Issue'
}

{ #category : 'instance creation' }
IssueManager class >> default [
	"Get the default shared instance"
	
	^ default ifNil: [ default := self new ]
]

{ #category : 'instance creation' }
IssueManager class >> new [
	^ super new initialize
]

{ #category : 'instance creation' }
IssueManager class >> reset [
	"Reset the default instance"
	
	default := nil
]

{ #category : 'initialization' }
IssueManager >> addDependency: dependencyIssue to: anIssue [
	"Add a dependency to an issue"
	
	anIssue ifNil: [ ^ false ].
	dependencyIssue ifNil: [ ^ false ].
	
	[ 
		anIssue addDependency: dependencyIssue.
		repository autoSave.
		^ true
	] on: Error do: [ :ex | 
		^ false ].
]

{ #category : 'initialization' }
IssueManager >> allIssues [
	"Get all issues from the repository"
	^ repository allIssues
]

{ #category : 'initialization' }
IssueManager >> availableDependenciesFor: anIssue [
	"Get available issues that can be added as dependencies to the given issue"
	
	anIssue ifNil: [ ^ #() ].
	
	^ anIssue dependencyHandler 
		availableDependenciesIn: self allIssues
]

{ #category : 'initialization' }
IssueManager >> canMoveDown: anIssue [
	"Check if an issue can be moved down"
	| allIssues currentIndex |
	
	anIssue ifNil: [ ^ false ].
	
	allIssues := self allIssues.
	currentIndex := allIssues indexOf: anIssue.
	
	^ currentIndex < allIssues size
]

{ #category : 'initialization' }
IssueManager >> canMoveUp: anIssue [
	"Check if an issue can be moved up"
	| allIssues currentIndex |
	
	anIssue ifNil: [ ^ false ].
	
	allIssues := self allIssues.
	currentIndex := allIssues indexOf: anIssue.
	
	^ currentIndex > 1
]

{ #category : 'initialization' }
IssueManager >> createIssue [
	"Create and return a new issue"
	| issue |
	
	issue := Issue new.
	repository addIssue: issue.
	
	^ issue
]

{ #category : 'initialization' }
IssueManager >> deleteIssue: anIssue [
	"Delete an issue and clean up all references to it"
	
	anIssue ifNil: [ ^ self ].
	
	"Remove this issue from all other issues' dependencies"
	self allIssues do: [ :otherIssue |
		otherIssue dependencies remove: anIssue ifAbsent: [] ].
	
	"Remove from repository"
	repository removeIssue: anIssue.
	
	"Auto-save changes"
	repository autoSave
]

{ #category : 'initialization' }
IssueManager >> findBlockedIssues [
	"Find issues that are blocked (status = #blocked)"
	
	^ self findIssuesByStatus: #blocked
]

{ #category : 'initialization' }
IssueManager >> findIssueById: anId [
	"Find an issue by its ID"
	
	^ self allIssues 
		detect: [ :issue | issue id = anId ]
		ifNone: [ nil ]
]

{ #category : 'initialization' }
IssueManager >> findIssuesByPriority: aPriority [
	"Find all issues with the given priority"
	
	^ self allIssues select: [ :issue | issue priority = aPriority ]
]

{ #category : 'initialization' }
IssueManager >> findIssuesByStatus: aStatus [
	"Find all issues with the given status"
	
	^ self allIssues select: [ :issue | issue status = aStatus ]
]

{ #category : 'initialization' }
IssueManager >> findIssuesWithDependencies [
	"Find all issues that have dependencies"
	
	^ self allIssues select: [ :issue | issue hasDependencies ]
]

{ #category : 'initialization' }
IssueManager >> initialize [
	super initialize.
	repository := IssueRepository uniqueInstance
]

{ #category : 'initialization' }
IssueManager >> isValid: anIssue [
	"Check if an issue is valid"
	
	^ (self validateIssue: anIssue) isEmpty
]

{ #category : 'initialization' }
IssueManager >> issueCount [
	"Get the total number of issues"
	
	^ self allIssues size
]

{ #category : 'initialization' }
IssueManager >> issueCountByPriority [
	"Get a dictionary of issue counts by priority"
	| counts |
	
	counts := Dictionary new.
	
	self allIssues do: [ :issue |
		| priority currentCount |
		priority := issue priority.
		currentCount := counts at: priority ifAbsent: [ 0 ].
		counts at: priority put: currentCount + 1 ].
	
	^ counts
]

{ #category : 'initialization' }
IssueManager >> issueCountByStatus [
	"Get a dictionary of issue counts by status"
	| counts |
	
	counts := Dictionary new.
	
	self allIssues do: [ :issue |
		| status currentCount |
		status := issue status.
		currentCount := counts at: status ifAbsent: [ 0 ].
		counts at: status put: currentCount + 1 ].
	
	^ counts
]

{ #category : 'initialization' }
IssueManager >> moveIssueDown: anIssue [
	"Move an issue down in the list (towards last index)"
	| allIssues currentIndex |
	
	anIssue ifNil: [ ^ false ].
	
	allIssues := self allIssues.
	currentIndex := allIssues indexOf: anIssue.
	
	currentIndex < allIssues size ifFalse: [ ^ false ].
	
	"Swap directly in the repository's internal collection"
	repository swapIssueAt: currentIndex with: currentIndex + 1.
	
	^ true
]

{ #category : 'initialization' }
IssueManager >> moveIssueUp: anIssue [
	"Move an issue up in the list (towards index 1)"
	| allIssues currentIndex |
	
	anIssue ifNil: [ ^ false ].
	
	allIssues := self allIssues.
	currentIndex := allIssues indexOf: anIssue.
	
	currentIndex > 1 ifFalse: [ ^ false ].
	
	"Swap directly in the repository's internal collection"
	repository swapIssueAt: currentIndex with: currentIndex - 1.
	
	^ true
]

{ #category : 'initialization' }
IssueManager >> removeDependency: dependencyIssue from: anIssue [
	"Remove a dependency from an issue"
	
	anIssue ifNil: [ ^ false ].
	dependencyIssue ifNil: [ ^ false ].
	
	anIssue removeDependency: dependencyIssue.
	repository autoSave.
	
	^ true
]

{ #category : 'initialization' }
IssueManager >> repository [
	^ repository
]

{ #category : 'initialization' }
IssueManager >> repository: anIssueRepository [
	repository := anIssueRepository
]

{ #category : 'initialization' }
IssueManager >> updateIssue: anIssue with: attributes [
	"Update an issue with the provided attributes dictionary"
	
	anIssue ifNil: [ ^ self ].
	
	attributes at: #title ifPresent: [ :value | anIssue title: value ].
	attributes at: #description ifPresent: [ :value | anIssue description: value ].
	attributes at: #status ifPresent: [ :value | anIssue status: value ].
	attributes at: #priority ifPresent: [ :value | anIssue priority: value ].
	attributes at: #startDate ifPresent: [ :value | anIssue startDate: value ].
	attributes at: #duration ifPresent: [ :value | anIssue duration: value ].
	attributes at: #dueDate ifPresent: [ :value | anIssue dueDate: value ].
	
	"Auto-save changes"
	repository autoSave
]

{ #category : 'initialization' }
IssueManager >> validateIssue: anIssue [
	"Validate an issue and return a collection of error messages"
	| errors |
	
	errors := OrderedCollection new.
	
	anIssue title ifNil: [ errors add: 'Title is required' ].
	anIssue title ifNotNil: [ 
		anIssue title isEmpty ifTrue: [ errors add: 'Title cannot be empty' ] ].
	
	anIssue status ifNil: [ errors add: 'Status is required' ].
	anIssue priority ifNil: [ errors add: 'Priority is required' ].
	
	(anIssue startDate notNil and: [ anIssue dueDate notNil ]) ifTrue: [
		anIssue startDate > anIssue dueDate ifTrue: [
			errors add: 'Start date must be before due date' ] ].
	
	^ errors
]
