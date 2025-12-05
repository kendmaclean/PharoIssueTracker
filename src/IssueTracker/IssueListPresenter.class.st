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
	
	"Dependencies indicator column - clickable"
	issueTable addColumn: ((SpStringTableColumn
		title: 'Deps'
		evaluated: [ :issue | 
			issue hasDependencies 
				ifTrue: [ '🔗 ', issue dependencies size asString ]
				ifFalse: [ '-' ] ])
		width: 60;
		compareFunction: [ :a :b | a dependencies size < b dependencies size ];
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
	
	"Select issue on single click"
	issueTable whenSelectedDo: [ :issue | 
		self owner onIssueSelected: issue ].
	
	"Add context menu for dependencies"
	issueTable contextMenu: [ 
		| selectedIssue contextMenu |
		selectedIssue := issueTable selection selectedItem.
		contextMenu := self newMenu.
		selectedIssue ifNotNil: [
			selectedIssue hasDependencies ifTrue: [
				contextMenu addItem: [ :item |
					item 
						name: 'Manage Dependencies (', selectedIssue dependencies size asString, ')';
						icon: (self iconNamed: #link);
						action: [ IssueDependencyDialog openFor: selectedIssue.
							self owner issueListChanged ] ] ] 
			ifFalse: [
				contextMenu addItem: [ :item |
					item 
						name: 'Add Dependencies';
						icon: (self iconNamed: #link);
						action: [ IssueDependencyDialog openFor: selectedIssue.
							self owner issueListChanged ] ] ] ].
		contextMenu ]
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
