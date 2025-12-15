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
IssueListPresenter >> computeDelay: anIssue [
	"Compute delay in days for an issue"
	| originalStart actualStart |
	originalStart := anIssue computedStartDate.
	actualStart := anIssue dependencyAwareStartDate.
	
	(originalStart isNil or: [ actualStart isNil ]) 
		ifTrue: [ ^ 0 ].
	
	^ actualStart asDate julianDayNumber 
		- originalStart asDate julianDayNumber max: 0
]

{ #category : 'initialization' }
IssueListPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		add: issueTable;
		yourself
]

{ #category : 'initialization' }
IssueListPresenter >> formatDelay: anIssue [
	"Format delay column - shows days delayed in red"
	| delay delayText |
	
	delay := self computeDelay: anIssue.
	
	delay = 0 ifTrue: [ ^ '-' ].
	
	delayText := '+' , delay asString.
	
	^ (delayText asText)
		addAttribute: (TextColor color: Color red);
		yourself
]

{ #category : 'initialization' }
IssueListPresenter >> formatDueDate: anIssue [
	"Format due date - returns colored text if delayed"
	| originalDue actualDue delay dateText |
	
	originalDue := anIssue computedDueDate.
	actualDue := anIssue dependencyAwareEndDate.
	
	actualDue ifNil: [ 
		^ anIssue dueDate
			ifNil: [ '-' ]
			ifNotNil: [ :d | d asDate yyyymmdd asString ] ].
	
	dateText := actualDue asDate yyyymmdd asString.
	
	"Check if delayed"
	originalDue ifNotNil: [
		delay := actualDue asDate julianDayNumber 
			- originalDue asDate julianDayNumber.
		delay > 0 ifTrue: [ 
			^ (dateText asText)
				addAttribute: (TextColor color: Color red);
				yourself ] ].
	
	^ dateText
]

{ #category : 'initialization' }
IssueListPresenter >> formatStartDate: anIssue [
	"Format start date - returns colored text if delayed"
	| originalStart actualStart delay dateText |
	
	originalStart := anIssue computedStartDate.
	actualStart := anIssue dependencyAwareStartDate.
	
	actualStart ifNil: [ 
		^ anIssue startDate
			ifNil: [ '-' ]
			ifNotNil: [ :d | d asDate yyyymmdd asString ] ].
	
	dateText := actualStart asDate yyyymmdd asString.
	
	"Check if delayed"
	originalStart ifNotNil: [
		delay := actualStart asDate julianDayNumber 
			- originalStart asDate julianDayNumber.
		delay > 0 ifTrue: [ 
			^ (dateText asText)
				addAttribute: (TextColor color: Color red);
				yourself ] ].
	
	^ dateText
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
				 priorities := #( low medium high critical ).
				 (priorities indexOf: a priority)
				 < (priorities indexOf: b priority) ];
			 yourself).

	"Title column - main content"
	issueTable addColumn: ((SpStringTableColumn
			  title: 'Title'
			  evaluated: [ :issue | issue title ])
			 beSortable;
			 compareFunction: [ :a :b |
				 a title asLowercase < b title asLowercase ];
			 yourself).

	"Dependencies indicator column - clickable"
	issueTable addColumn:
		((SpStringTableColumn title: 'Deps' evaluated: [ :issue |
				  issue hasDependencies
					  ifTrue: [ '🔗 ' , issue dependencies size asString ]
					  ifFalse: [ '-' ] ])
			 width: 60;
			 beSortable;
			 compareFunction: [ :a :b |
				 a dependencies size < b dependencies size ];
			 yourself).

	"Status column"
	issueTable addColumn: ((SpStringTableColumn
			  title: 'Status'
			  evaluated: [ :issue | issue status asString ])
			 width: 100;
			 beSortable;
			 compareFunction: [ :a :b |
				 | statuses |
				 statuses := #( open inProgress resolved closed milestone ).
				 (statuses indexOf: a status) < (statuses indexOf: b status) ];
			 yourself).

	"Start date column - shows dependency-aware date in red if delayed"
	issueTable addColumn:
		((SpStringTableColumn title: 'Start' evaluated: [ :issue |
			  self formatStartDate: issue ])
			 width: 110;
			 beSortable;
			 compareFunction: [ :a :b |
				 | aDate bDate |
				 aDate := a dependencyAwareStartDate ifNil: [ 
					          a startDate ifNil: [ Date new year: 9999 ] ].
				 bDate := b dependencyAwareStartDate ifNil: [ 
					          b startDate ifNil: [ Date new year: 9999 ] ].
				 aDate < bDate ];
			 yourself).

	"Delay column - shows how many days delayed due to dependencies"
	issueTable addColumn:
		((SpStringTableColumn title: '⚠' evaluated: [ :issue |
			  self formatDelay: issue ])
			 width: 45;
			 beSortable;
			 compareFunction: [ :a :b |
				 | aDelay bDelay |
				 aDelay := self computeDelay: a.
				 bDelay := self computeDelay: b.
				 aDelay < bDelay ];
			 yourself).

	"Duration column"
	issueTable addColumn:
		((SpStringTableColumn title: 'Dur' evaluated: [ :issue |
			  issue duration
				  ifNil: [ '-' ]
				  ifNotNil: [ :d | d asString ] ])
			 width: 50;
			 beSortable;
			 compareFunction: [ :a :b |
			 | aDur bDur |
			 aDur := a duration ifNil: [ 0 ].
			 bDur := b duration ifNil: [ 0 ].
			 aDur < bDur ];
			 yourself).

	"Due date column - shows dependency-aware date in red if delayed"
	issueTable addColumn:
		((SpStringTableColumn title: 'Due' evaluated: [ :issue |
			  self formatDueDate: issue ])
			 width: 110;
			 beSortable;
			 compareFunction: [ :a :b |
				 | aDate bDate |
				 aDate := a dependencyAwareEndDate ifNil: [ 
					          a dueDate ifNil: [ Date new year: 9999 ] ].
				 bDate := b dependencyAwareEndDate ifNil: [ 
					          b dueDate ifNil: [ Date new year: 9999 ] ].
				 aDate < bDate ];
			 yourself).

	"Select issue on single click"
	issueTable whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :issue |
			self owner onIssueSelected: issue ] ].

	"Add context menu for dependencies"
	issueTable contextMenu: [
		| selectedIssue contextMenu dialog |
		selectedIssue := issueTable selection selectedItem.
		contextMenu := self newMenu.
		selectedIssue ifNotNil: [
			selectedIssue hasDependencies
				ifTrue: [
					contextMenu addItem: [ :item |
						item
							name:
								'Manage Dependencies ('
								, selectedIssue dependencies size asString , ')';
							icon: (self iconNamed: #link);
							action: [ "Create dialog and set callback"
								dialog := IssueDependencyDialog new.
								dialog issue: selectedIssue.
								dialog onDependencyChanged: [ self owner issueListChanged ].
								dialog open ] ] ]
				ifFalse: [
					contextMenu addItem: [ :item |
						item
							name: 'Add Dependencies';
							icon: (self iconNamed: #link);
							action: [ "Create dialog and set callback"
								dialog := IssueDependencyDialog new.
								dialog issue: selectedIssue.
								dialog onDependencyChanged: [ self owner issueListChanged ].
								dialog open ] ] ] ].
		contextMenu ]
]

{ #category : 'initialization' }
IssueListPresenter >> items: aCollection [
	issueTable items: aCollection
]

{ #category : 'initialization' }
IssueListPresenter >> selectItem: anIssue [
	"Select a specific item in the table"
	issueTable selectItem: anIssue
]

{ #category : 'initialization' }
IssueListPresenter >> selectedItem [
	^ issueTable selectedItem
]

{ #category : 'initialization' }
IssueListPresenter >> unselectAll [
	issueTable unselectAll
]
