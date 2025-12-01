Class {
	#name : 'IssueTrackerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'issueList',
		'titleInput',
		'descriptionInput',
		'priorityDropdown',
		'addButton',
		'statusDropdown',
		'deleteButton',
		'chartButton',
		'issues'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssueTrackerPresenter class >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'Issue Tracker';
        initialExtent: 600@500
]

{ #category : 'instance creation' }
IssueTrackerPresenter class >> open [
    <script>
    ^ self new open
]

{ #category : 'initialization' }
IssueTrackerPresenter >> addIssue [
    | issue |
    titleInput text ifEmpty: [ 
        self inform: 'Please enter a title'.
        ^ self ].
    
    issue := Issue new.
    issue title: titleInput text.
    issue description: descriptionInput text.
    issue priority: priorityDropdown selectedItem.
    issue status: statusDropdown selectedItem.
    
    issues add: issue.
    self updateIssueList.
    
    titleInput text: ''.
    descriptionInput text: ''
]

{ #category : 'initialization' }
IssueTrackerPresenter >> colorForStatus: aStatus [
    aStatus = #open ifTrue: [ ^ Color cyan ].
    aStatus = #inProgress ifTrue: [ ^ Color orange ].
    aStatus = #resolved ifTrue: [ ^ Color green ].
    aStatus = #closed ifTrue: [ ^ Color gray ].
    ^ Color black
]

{ #category : 'initialization' }
IssueTrackerPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom
        spacing: 5;
        add: (SpBoxLayout newLeftToRight
            add: 'Title:' expand: false;
            add: titleInput;
            yourself) expand: false;
        add: (SpBoxLayout newLeftToRight
            add: 'Priority:' expand: false;
            add: priorityDropdown;
            add: 'Status:' expand: false;
            add: statusDropdown;
            yourself) expand: false;
        add: (SpBoxLayout newLeftToRight
            add: 'Description:' expand: false;
            add: descriptionInput;
            yourself);
        add: (SpBoxLayout newLeftToRight
            add: addButton;
            add: deleteButton;
            add: chartButton;
            yourself) expand: false;
        add: 'Issues:' expand: false;
        add: issueList;
        yourself
]

{ #category : 'initialization' }
IssueTrackerPresenter >> deleteIssue [
    issueList selectedItem ifNotNil: [ :issue |
        issues remove: issue.
        self updateIssueList.
        deleteButton disable ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> initializePresenters [
    issues := OrderedCollection new.
    
    issueList := self newList.
    issueList display: [ :issue | issue displayString ].
    issueList whenSelectedDo: [ :issue | self onIssueSelected: issue ].
    
    titleInput := self newTextInput.
    titleInput placeholder: 'Issue title...'.
    
    descriptionInput := self newText.
    descriptionInput placeholder: 'Issue description...'.
    
    priorityDropdown := self newDropList.
    priorityDropdown items: #(low medium high critical).
    priorityDropdown selectIndex: 2.
    
    statusDropdown := self newDropList.
    statusDropdown items: #(open inProgress resolved closed).
    statusDropdown selectIndex: 1.
    statusDropdown whenSelectedItemChangedDo: [ :item | self onStatusChanged ].
    
    addButton := self newButton.
    addButton label: 'Add Issue'.
    addButton action: [ self addIssue ].
    
    deleteButton := self newButton.
    deleteButton label: 'Delete'.
    deleteButton action: [ self deleteIssue ].
    deleteButton disable.
    
    chartButton := self newButton.
    chartButton label: 'View Chart'.
    chartButton action: [ self showChart ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onIssueSelected: anIssue [
    anIssue ifNotNil: [
        titleInput text: anIssue title.
        descriptionInput text: anIssue description.
        statusDropdown selectItem: anIssue status.
        priorityDropdown selectItem: anIssue priority.
        deleteButton enable ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onStatusChanged [
    issueList selectedItem ifNotNil: [ :issue |
        issue status: statusDropdown selectedItem.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> showChart [
    | canvas builder shapes legend statusCounts bars |
    issues ifEmpty: [ 
        self inform: 'No issues to display'.
        ^ self ].
    
    canvas := RSCanvas new.
    
    statusCounts := Dictionary new.
    #(open inProgress resolved closed) do: [ :status |
        statusCounts at: status put: (issues count: [ :i | i status = status ]) ].
    
    builder := RSChart new.
    builder extent: 600@400.
    
    bars := statusCounts associations collect: [ :assoc |
        | bar label |
        bar := RSBox new
            width: 80;
            height: (assoc value * 30 max: 5);
            color: (self colorForStatus: assoc key);
            model: assoc;
            yourself.
        
        label := RSLabel new
            text: assoc key asString, String cr, assoc value asString;
            fontSize: 10.
        
        RSComposite new
            shapes: { bar. label };
            yourself ].
    
    canvas addAll: bars.
    RSHorizontalLineLayout on: bars.
    
    canvas @ RSCanvasController.
    
    canvas open setLabel: 'Issue Status Chart'
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateIssueList [
    issueList items: issues
]
