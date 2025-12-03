Class {
	#name : 'IssueDetailsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleInput',
		'descriptionInput',
		'priorityDropdown',
		'statusDropdown',
		'dueDateInput',
		'addButton',
		'deleteButton',
		'isLoadingIssue'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
IssueDetailsPresenter >> clearForm [
	titleInput text: ''.
	descriptionInput text: ''.
	dueDateInput date: nil.
	priorityDropdown selectIndex: 2.
	statusDropdown selectIndex: 1.
	self updateButtonStates
]

{ #category : 'initialization' }
IssueDetailsPresenter >> createNewIssue [
	| issue |
	titleInput text ifEmpty: [
		self inform: 'Please enter a title'.
		^ self ].
	
	issue := Issue new
		title: titleInput text;
		description: descriptionInput text;
		priority: priorityDropdown selectedItem;
		status: statusDropdown selectedItem;
		dueDate: dueDateInput date;
		yourself.
	
	IssueRepository uniqueInstance addIssue: issue.
	
	self clearForm.
	self owner issueListChanged
]

{ #category : 'initialization' }
IssueDetailsPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 8;
		add: 'Issue Details' expand: false;
		add: (SpBoxLayout newLeftToRight
			add: 'Title:' width: 80;
			add: titleInput;
			yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
			add: 'Priority:' width: 80;
			add: priorityDropdown width: 120;
			add: 'Status:' width: 80;
			add: statusDropdown width: 120;
			add: 'Due Date:' width: 80;
			add: dueDateInput;
			yourself)
		expand: false;
		add: 'Description:' expand: false;
		add: descriptionInput height: 100;
		add: (SpBoxLayout newLeftToRight
			spacing: 5;
			add: addButton;
			add: deleteButton;
			yourself)
		expand: false;
		yourself
]

{ #category : 'initialization' }
IssueDetailsPresenter >> deleteIssue [
	self owner deleteCurrentIssue
]

{ #category : 'initialization' }
IssueDetailsPresenter >> descriptionText [
	^ descriptionInput text asString
]

{ #category : 'initialization' }
IssueDetailsPresenter >> hasCurrentIssue [
	^ self owner hasCurrentIssue
]

{ #category : 'initialization' }
IssueDetailsPresenter >> initializePresenters [
	isLoadingIssue := false.
	
	"Title"
	titleInput := self newTextInput
		placeholder: 'Issue title...';
		yourself.
	titleInput whenTextChangedDo: [ self onFieldChanged ].
	
	"Description"
	descriptionInput := self newText
		placeholder: 'Description...';
		yourself.
	descriptionInput whenTextChangedDo: [ self onFieldChanged ].
	
	"Due Date"
	dueDateInput := self instantiate: SpDatePresenter.
	dueDateInput whenDateChanged: [ self onFieldChanged ].
	
	"Priority"
	priorityDropdown := self newDropList
		items: #( low medium high critical );
		selectIndex: 2;
		yourself.
	priorityDropdown whenSelectedItemChangedDo: [ self onFieldChanged ].
	
	"Status"
	statusDropdown := self newDropList
		items: #( open inProgress resolved closed );
		selectIndex: 1;
		yourself.
	statusDropdown whenSelectedItemChangedDo: [ self onFieldChanged ].
	
	"Action buttons"
	addButton := self newButton
		label: 'Create New Issue';
		icon: (self iconNamed: #add);
		action: [ self createNewIssue ];
		yourself.
		
	deleteButton := self newButton
		label: 'Delete Issue';
		icon: (self iconNamed: #delete);
		action: [ self deleteIssue ];
		yourself
]

{ #category : 'initialization' }
IssueDetailsPresenter >> loadIssue: anIssue [
	isLoadingIssue := true.
	anIssue ifNotNil: [
		titleInput text: anIssue title.
		descriptionInput text: (anIssue description ifNil: [ '' ]).
		statusDropdown selectItem: anIssue status.
		priorityDropdown selectItem: anIssue priority.
		dueDateInput date: anIssue dueDate ].
	isLoadingIssue := false.
	self updateButtonStates
]

{ #category : 'initialization' }
IssueDetailsPresenter >> onFieldChanged [
	"Notify owner when fields change"
	isLoadingIssue ifTrue: [ ^ self ].
	self owner fieldChanged
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedDueDate [
	^ dueDateInput date
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedPriority [
	^ priorityDropdown selectedItem
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedStatus [
	^ statusDropdown selectedItem
]

{ #category : 'initialization' }
IssueDetailsPresenter >> titleText [
	^ titleInput text asString
]

{ #category : 'initialization' }
IssueDetailsPresenter >> updateButtonStates [
	deleteButton enabled: self owner hasCurrentIssue
]
