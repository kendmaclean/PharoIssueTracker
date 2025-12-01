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
		'issues',
		'sortByPriorityButton',
		'sortByDateButton',
		'hideClosedButton',
		'hideClosedIssues',
		'dueDateInput',
		'dueDateFilter',
		'showTodayButton',
		'showWeekButton',
		'showAllButton'
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
    issue dueDate: dueDateInput date.
    
    issues add: issue.
    self updateIssueList.
    
    titleInput text: ''.
    descriptionInput text: ''.
    dueDateInput date: nil
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
            add: 'Due Date:' expand: false;
            add: dueDateInput;
            add: (self newButton 
                label: 'Update Date';
                action: [ self updateDueDate ];
                yourself) expand: false;
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
        add: (SpBoxLayout newLeftToRight
            add: (SpBoxLayout newTopToBottom
                spacing: 5;
                add: showTodayButton expand: false;
                add: showWeekButton expand: false;
                add: hideClosedButton expand: false;
                add: showAllButton expand: false;
                yourself) width: 120;
            add: issueList;
            yourself);
        add: (SpBoxLayout newLeftToRight
            add: sortByPriorityButton;
            add: sortByDateButton;
            yourself) expand: false;
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
	hideClosedIssues := false.
	dueDateFilter := #all.

	issueList := self newList.
	issueList display: [ :issue | issue displayString ].
	issueList whenSelectedDo: [ :issue | self onIssueSelected: issue ].

	titleInput := self newTextInput.
	titleInput placeholder: 'Issue title...'.
	titleInput whenTextChangedDo: [ :newText |
		self onTitleChanged: newText ].

	descriptionInput := self newText.
	descriptionInput placeholder: 'Issue description...'.
	descriptionInput whenTextChangedDo: [ :newText |
		self onDescriptionChanged: newText ].

	dueDateInput := self instantiate: SpDatePresenter.
	dueDateInput whenDateChanged: [ :newText |
		self onDueDateChanged: newText ].


	priorityDropdown := self newDropList.
	priorityDropdown items: #( low medium high critical ).
	priorityDropdown selectIndex: 2.
	priorityDropdown whenSelectedItemChangedDo: [ :item |
		self onPriorityChanged ].

	statusDropdown := self newDropList.
	statusDropdown items: #( open inProgress resolved closed ).
	statusDropdown selectIndex: 1.
	statusDropdown whenSelectedItemChangedDo: [ :item |
		self onStatusChanged ].

	addButton := self newButton.
	addButton label: 'Add Issue'.
	addButton action: [ self addIssue ].

	deleteButton := self newButton.
	deleteButton label: 'Delete'.
	deleteButton action: [ self deleteIssue ].
	deleteButton disable.

	chartButton := self newButton.
	chartButton label: 'View Chart'.
	chartButton action: [ self showChart ].

	sortByPriorityButton := self newButton.
	sortByPriorityButton label: 'Sort by Priority'.
	sortByPriorityButton action: [ self sortByPriority ].

	sortByDateButton := self newButton.
	sortByDateButton label: 'Sort by Due Date'.
	sortByDateButton action: [ self sortByDueDate ].

	hideClosedButton := self newButton.
	hideClosedButton label: 'Hide Closed'.
	hideClosedButton action: [ self toggleHideClosed ].

	showTodayButton := self newButton.
	showTodayButton label: 'Due Today'.
	showTodayButton action: [ self showDueToday ].

	showWeekButton := self newButton.
	showWeekButton label: 'Due This Week'.
	showWeekButton action: [ self showDueThisWeek ].

	showAllButton := self newButton.
	showAllButton label: 'Show All'.
	showAllButton action: [ self showAllDueDates ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onDescriptionChanged: newText [
    issueList selectedItem ifNotNil: [ :issue |
        issue description: newText ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onDueDateChanged: newDate [
    issueList selectedItem ifNotNil: [ :issue |
        issue dueDate: newDate.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onIssueSelected: anIssue [
    anIssue ifNotNil: [
        titleInput text: anIssue title.
        descriptionInput text: anIssue description.
        statusDropdown selectItem: anIssue status.
        priorityDropdown selectItem: anIssue priority.
        dueDateInput date: anIssue dueDate.
        deleteButton enable ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onPriorityChanged [
    issueList selectedItem ifNotNil: [ :issue |
        issue priority: priorityDropdown selectedItem.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onStatusChanged [
    issueList selectedItem ifNotNil: [ :issue |
        issue status: statusDropdown selectedItem.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onTitleChanged: newText [
    issueList selectedItem ifNotNil: [ :issue |
        issue title: newText.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> showAllDueDates [
    dueDateFilter := #all.
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> showChart [
    | canvas builder statusCounts bars |
    issues ifEmpty: [ 
        self inform: 'No issues to display'.
        ^ self ].
    
    canvas := RSCanvas new.
    
    statusCounts := Dictionary new.
    #(open inProgress resolved closed) do: [ :status |
        statusCounts at: status put: (issues count: [ :i | i status = status ]) ].
    
    builder := RSCompositeChart new.
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
IssueTrackerPresenter >> showDueThisWeek [
    dueDateFilter := #week.
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> showDueToday [
    dueDateFilter := #today.
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> sortByDate [
    issues := issues sorted: [ :a :b | 
        a createdAt > b createdAt ].
    
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> sortByDueDate [
    issues := issues sorted: [ :a :b | 
        | aDate bDate |
        aDate := a dueDate ifNil: [ Date today addDays: 10000 ].
        bDate := b dueDate ifNil: [ Date today addDays: 10000 ].
        aDate < bDate ].
    
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> sortByPriority [
    | priorityOrder |
    priorityOrder := Dictionary new
        at: #critical put: 1;
        at: #high put: 2;
        at: #medium put: 3;
        at: #low put: 4;
        yourself.
    
    issues := issues sorted: [ :a :b | 
        (priorityOrder at: a priority) < (priorityOrder at: b priority) ].
    
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> toggleHideClosed [
    hideClosedIssues := hideClosedIssues not.
    
    hideClosedButton label: (hideClosedIssues
        ifTrue: [ 'Show Closed' ]
        ifFalse: [ 'Hide Closed' ]).
    
    self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateDueDate [
    issueList selectedItem ifNotNil: [ :issue |
        issue dueDate: dueDateInput date.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateIssueList [
    | filteredIssues |
    filteredIssues := issues.
    
    "Apply closed filter"
    hideClosedIssues ifTrue: [
        filteredIssues := filteredIssues reject: [ :issue | issue status = #closed ] ].
    
    "Apply due date filter"
    dueDateFilter = #today ifTrue: [
        filteredIssues := filteredIssues select: [ :issue |
            issue dueDate notNil and: [ issue dueDate asDate = Date today ] ] ].
    
    dueDateFilter = #week ifTrue: [
        | today weekFromNow |
        today := Date today.
        weekFromNow := today addDays: 7.
        filteredIssues := filteredIssues select: [ :issue |
            issue dueDate notNil and: [ 
                issue dueDate asDate between: today and: weekFromNow ] ] ].
    
    issueList items: filteredIssues
]
