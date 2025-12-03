Class {
	#name : 'IssueListPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'issueTable'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
IssueListPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		add: issueTable;
		yourself
]

{ #category : 'initialization' }
IssueListPresenter >> initializePresenters [
	issueTable := self newTable.
	
	"Priority column with color coding"
	issueTable addColumn: ((SpStringTableColumn
		title: 'P'
		evaluated: [ :issue |
			issue priority asString first asUppercase asString ])
		width: 30;
		compareFunction: [ :a :b | a priority < b priority ];
		yourself).
	
	"Title column - main content"
	issueTable addColumn: ((SpStringTableColumn
		title: 'Title'
		evaluated: [ :issue | issue title ]) 
		compareFunction: [ :a :b | a title < b title ];
		yourself).
	
	"Status column"
	issueTable addColumn: ((SpStringTableColumn
		title: 'Status'
		evaluated: [ :issue | issue status asString ])
		width: 100;
		compareFunction: [ :a :b | a status < b status ];
		yourself).
	
	"Due date column"
	issueTable addColumn:
		((SpStringTableColumn title: 'Due' evaluated: [ :issue |
			issue dueDate
				ifNil: [ '-' ]
				ifNotNil: [ :d | d asDate asString ] ])
		width: 110;
		compareFunction: [ :a :b | a dueDate < b dueDate ];
		yourself).
	
	issueTable whenSelectedDo: [ :issue | 
		self owner onIssueSelected: issue ]
]

{ #category : 'initialization' }
IssueListPresenter >> items: aCollection [
	issueTable items: aCollection
]

{ #category : 'initialization' }
IssueListPresenter >> selectedItem [
	^ issueTable selectedItem
]

{ #category : 'initialization' }
IssueListPresenter >> unselectAll [
	issueTable unselectAll
]
