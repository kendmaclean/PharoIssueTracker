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
		beSortable;
		compareFunction: [ :a :b | 
			| priorities |
			priorities := #(low medium high critical).
			(priorities indexOf: a priority) < (priorities indexOf: b priority) ];
		yourself).
	
	"Title column - main content"
	issueTable addColumn: ((SpStringTableColumn
		title: 'Title'
		evaluated: [ :issue | issue title ])
		beSortable;
		compareFunction: [ :a :b | a title asLowercase < b title asLowercase ];
		yourself).
	
	"Dependencies indicator column - clickable"
	issueTable addColumn: ((SpStringTableColumn
		title: 'Deps'
		evaluated: [ :issue | 
			issue hasDependencies 
				ifTrue: [ '🔗 ', issue dependencies size asString ]
				ifFalse: [ '-' ] ])
		width: 60;
		beSortable;
		compareFunction: [ :a :b | a dependencies size < b dependencies size ];
		yourself).
	
	"Status column"
	issueTable addColumn: ((SpStringTableColumn
		title: 'Status'
		evaluated: [ :issue | issue status asString ])
		width: 100;
		beSortable;
		compareFunction: [ :a :b | 
			| statuses |
			statuses := #(open inProgress resolved closed milestone).
			(statuses indexOf: a status) < (statuses indexOf: b status) ];
		yourself).
	
	"Due date column"
	issueTable addColumn:
		((SpStringTableColumn title: 'Due' evaluated: [ :issue |
			issue dueDate
				ifNil: [ '-' ]
				ifNotNil: [ :d | d asDate asString ] ])
		width: 110;
		beSortable;
		compareFunction: [ :a :b | 
			| aDate bDate |
			aDate := a dueDate ifNil: [ Date new year: 9999 ].
			bDate := b dueDate ifNil: [ Date new year: 9999 ].
			aDate < bDate ];
		yourself).
	
	"Select issue on single click"
	issueTable whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :issue | 
			self owner onIssueSelected: issue ] ].
	
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
