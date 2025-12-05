Class {
	#name : 'Issue',
	#superclass : 'Object',
	#instVars : [
		'id',
		'title',
		'description',
		'status',
		'priority',
		'createdAt',
		'dueDate',
		'startDate',
		'duration',
		'dependencies'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
Issue >> addDependency: anIssue [
	"Delegate to handler"
	self dependencyHandler addDependency: anIssue
]

{ #category : 'accessing' }
Issue >> computedDueDate [
    "Returns the due date, computing it if needed"
    dueDate ifNotNil: [ ^ dueDate asDate ].
    
    "If no due date but have start date and duration, calculate forward"
    (startDate notNil and: [ duration notNil ]) ifTrue: [
        ^ startDate asDate addDays: duration ].
    
    ^ nil
]

{ #category : 'accessing' }
Issue >> computedDuration [
    | start end |
    "Returns the duration in days"
    duration ifNotNil: [ ^ duration ].
    
    "Calculate from dates if available"

    start := self computedStartDate.
    end := self computedDueDate.
    
    (start notNil and: [ end notNil ]) ifTrue: [
        ^ end asDate julianDayNumber - start asDate julianDayNumber ].
    
    ^ 1  "Default duration"
]

{ #category : 'accessing' }
Issue >> computedStartDate [
    "Returns the start date, computing it if needed"
    startDate ifNotNil: [ ^ startDate asDate ].
    
    "If no start date but have due date and duration, calculate backwards"
    (dueDate notNil and: [ duration notNil ]) ifTrue: [
        ^ dueDate asDate subtractDays: duration ].
    
    "Default to creation date"
    createdAt ifNotNil: [ ^ createdAt asDate ].
    
    "Fallback to today"
    ^ Date today
]

{ #category : 'initialization' }
Issue >> createdAt [
    ^ createdAt
]

{ #category : 'accessing' }
Issue >> createdAt: anObject [

	createdAt := anObject
]

{ #category : 'accessing' }
Issue >> dependencies [

	^ dependencies
]

{ #category : 'accessing' }
Issue >> dependencies: anObject [

	dependencies := anObject
]

{ #category : 'accessing' }
Issue >> dependencyAwareEndDate [
	"Delegate calculation to handler"
	^ self dependencyHandler resolveEndDate
]

{ #category : 'accessing' }
Issue >> dependencyAwareStartDate [
	"Delegate calculation to handler"
	^ self dependencyHandler resolveStartDate
]

{ #category : 'accessing' }
Issue >> dependencyHandler [
	^ IssueDependencyHandler new issue: self
]

{ #category : 'accessing' }
Issue >> description [

	^ description
]

{ #category : 'accessing' }
Issue >> description: anObject [

	description := anObject
]

{ #category : 'accessing' }
Issue >> displayString [

	| text dueDateStr descFirstLine |
	dueDateStr := dueDate
		              ifNil: [ 'No due date' ]
		              ifNotNil: [ dueDate asDate asString ].

	descFirstLine := description ifNil: [ '' ] ifNotNil: [
		                 | lines |
		                 lines := description lines.
		                 lines
			                 ifEmpty: [ '' ]
			                 ifNotEmpty: [
			                 ' - ' , (lines first truncateTo: 50) ] ].

    text := Text streamContents: [ :s |
        s << '[' << priority asString << '] '.
        s 
            nextPutAll: title asText allBold;
            nextPutAll: ' ('.
        s << status asString << ') - Due: '.
        s << dueDateStr.
        s << descFirstLine ].
    
    ^ text
]

{ #category : 'initialization' }
Issue >> dueDate [
    ^ dueDate
]

{ #category : 'initialization' }
Issue >> dueDate: aDate [
    dueDate := aDate
]

{ #category : 'accessing' }
Issue >> duration [

	^ duration
]

{ #category : 'accessing' }
Issue >> duration: anObject [

	duration := anObject
]

{ #category : 'initialization' }
Issue >> hasDependencies [
    ^ dependencies notEmpty
]

{ #category : 'accessing' }
Issue >> id [

	^ id
]

{ #category : 'accessing' }
Issue >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
Issue >> initialize [
    super initialize.
    id := UUID new asString.
    createdAt := DateAndTime now.
    status := #open.
    priority := #medium.
    dependencies := OrderedCollection new
]

{ #category : 'accessing' }
Issue >> priority [

	^ priority
]

{ #category : 'accessing' }
Issue >> priority: anObject [

	priority := anObject
]

{ #category : 'initialization' }
Issue >> removeDependency: anIssue [
	"Delegate to handler"
	self dependencyHandler removeDependency: anIssue
]

{ #category : 'accessing' }
Issue >> startDate [

	^ startDate
]

{ #category : 'accessing' }
Issue >> startDate: anObject [

	startDate := anObject
]

{ #category : 'accessing' }
Issue >> status [

	^ status
]

{ #category : 'accessing' }
Issue >> status: anObject [

	status := anObject
]

{ #category : 'accessing' }
Issue >> title [

	^ title
]

{ #category : 'accessing' }
Issue >> title: anObject [

	title := anObject
]

{ #category : 'initialization' }
Issue >> wouldCreateCircularDependency: anIssue [
    "Delegate to handler (if you still need this method exposed directly)"
    ^ self dependencyHandler detectsCycleWith: anIssue
]
