Class {
	#name : 'Issue',
	#superclass : 'Object',
	#instVars : [
		'id',
		'title',
		'description',
		'status',
		'priority',
		'createdAt'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'accessing' }
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
    ^ String streamContents: [ :s |
        s << '[' << priority asString << '] '.
        s << title.
        s << ' (' << status asString << ')' ]
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
