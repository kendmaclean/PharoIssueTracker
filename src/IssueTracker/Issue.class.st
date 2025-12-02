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
		'dueDate'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
Issue >> createdAt [
    ^ createdAt
]

{ #category : 'accessing' }
Issue >> createdAt: anObject [

	createdAt := anObject
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
    priority := #medium
]

{ #category : 'accessing' }
Issue >> priority [

	^ priority
]

{ #category : 'accessing' }
Issue >> priority: anObject [

	priority := anObject
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
