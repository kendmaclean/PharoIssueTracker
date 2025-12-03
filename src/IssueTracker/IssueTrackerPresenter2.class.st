Class {
	#name : 'IssueTrackerPresenter2',
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
		'showAllButton',
		'toolbar',
		'detailsBox',
		'currentIssue',
		'isLoadingIssue'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssueTrackerPresenter2 class >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'Issue Tracker';
        initialExtent: 600@500
]

{ #category : 'instance creation' }
IssueTrackerPresenter2 class >> open [
    <script>
    ^ self new open
]

{ #category : 'instance creation' }
IssueTrackerPresenter2 class >> startUp: resuming [
    resuming ifTrue: [ self open ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> addIssue [
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
    
    IssueRepository uniqueInstance addIssue: issue.
    issues := IssueRepository uniqueInstance allIssues.
    self updateIssueList.
    
    titleInput text: ''.
    descriptionInput text: ''.
    dueDateInput date: nil
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> clearForm [
	"Deselect in the list first to avoid triggering updates"
	issueList unselectAll.
	currentIssue := nil.
	titleInput text: ''.
	descriptionInput text: ''.
	dueDateInput date: nil.
	priorityDropdown selectIndex: 2.
	statusDropdown selectIndex: 1.
	self updateButtonStates
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> colorForStatus: aStatus [
    aStatus = #open ifTrue: [ ^ Color cyan ].
    aStatus = #inProgress ifTrue: [ ^ Color orange ].
    aStatus = #resolved ifTrue: [ ^ Color green ].
    aStatus = #closed ifTrue: [ ^ Color gray ].
    ^ Color black
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> createNewIssue [
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
	issues := IssueRepository uniqueInstance allIssues.
	
	self clearForm.
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 0;
		add: toolbar expand: false;
		add: (SpPanedLayout newTopToBottom
			positionOfSlider: 0.6;
			add: issueList;
			add: detailsBox;
			yourself);
		yourself
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> deleteIssue [
	currentIssue ifNotNil: [ :issue |
		(self confirm: 'Delete issue: ', issue title, '?') ifTrue: [
			IssueRepository uniqueInstance removeIssue: issue.
			issues := IssueRepository uniqueInstance allIssues.
			self clearForm.
			self updateIssueList ] ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> initializeDetailsForm [
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
		                yourself.

	detailsBox := SpBoxLayout newTopToBottom
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
IssueTrackerPresenter2 >> initializeList [

	issueList := self newTable.

	"Priority column with color coding"
	issueList addColumn: ((SpStringTableColumn
			  title: 'P'
			  evaluated: [ :issue |
				  issue priority asString first asUppercase asString ])
			 width: 30;
			 compareFunction: [ :a :b | a priority < b priority ];
			 yourself).

	"Title column - main content"
	issueList addColumn: ((SpStringTableColumn
			 title: 'Title'
			 evaluated: [ :issue | issue title ]) 
			 compareFunction: [ :a :b | a title < b title ];
			yourself).

	"Status column"
	issueList addColumn: ((SpStringTableColumn
			  title: 'Status'
			  evaluated: [ :issue | issue status asString ])
			 width: 100;
			 compareFunction: [ :a :b | a status < b status ];
			 yourself).

	"Due date column"
	issueList addColumn:
		((SpStringTableColumn title: 'Due' evaluated: [ :issue |
				  issue dueDate
					  ifNil: [ '-' ]
					  ifNotNil: [ :d | d asDate asString ] ])
			 width: 110;
			 compareFunction: [ :a :b | a dueDate < b dueDate ];
			 yourself).

	issueList whenSelectedDo: [ :issue | self onIssueSelected: issue ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> initializePresenters [
	issues := IssueRepository uniqueInstance allIssues.
	hideClosedIssues := false.
	dueDateFilter := #all.
	currentIssue := nil.
	isLoadingIssue := false.
	
	self initializeList.
	self initializeToolbar.
	self initializeDetailsForm.
	self updateIssueList.
	self updateButtonStates
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> initializeToolbar [

	toolbar := self newToolbar.

	"Filtering group"
	showAllButton := self newToolbarButton
		                 label: 'All';
		                 help: 'Show all issues';
		                 action: [ self showAllDueDates ];
		                 yourself.

	showTodayButton := self newToolbarButton
		                   label: 'Today';
		                   help: 'Show issues due today';
		                   action: [ self showDueToday ];
		                   yourself.

	showWeekButton := self newToolbarButton
		                  label: 'This Week';
		                  help: 'Show issues due this week';
		                  action: [ self showDueThisWeek ];
		                  yourself.

	hideClosedButton := self newToolbarButton
		                    label: 'Hide Closed';
		                    help: 'Toggle closed issues visibility';
		                    action: [ self toggleHideClosed ];
		                    yourself.

	toolbar addItem: showAllButton.
	toolbar addItem: showTodayButton.
	toolbar addItem: showWeekButton.
	toolbar addItem: hideClosedButton.

	"Actions group"
	chartButton := self newToolbarButton
		               label: 'Chart';
		               icon: (self iconNamed: #chart);
		               action: [ self showChart ];
		               yourself.

	toolbar addItem: chartButton
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Issue Tracker';
		initialExtent: 800 @ 750
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> onDescriptionChanged: newText [

	issueList selectedItem ifNotNil: [ :issue |
		issue description: newText.
		self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> onDueDateChanged: newDate [
    issueList selectedItem ifNotNil: [ :issue |
        issue dueDate: newDate.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> onFieldChanged [
	"Update the currently selected issue when fields change"
	isLoadingIssue ifTrue: [ ^ self ].
	currentIssue ifNotNil: [ :issue |
		issue title: titleInput text.
		issue description: descriptionInput text.
		issue status: statusDropdown selectedItem.
		issue priority: priorityDropdown selectedItem.
		issue dueDate: dueDateInput date.
		self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> onIssueSelected: anIssue [
	isLoadingIssue := true.
	currentIssue := anIssue.
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
IssueTrackerPresenter2 >> onPriorityChanged [
    issueList selectedItem ifNotNil: [ :issue |
        issue priority: priorityDropdown selectedItem.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> onStatusChanged [
    issueList selectedItem ifNotNil: [ :issue |
        issue status: statusDropdown selectedItem.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> onTitleChanged: newText [

	issueList selectedItem ifNotNil: [ :issue |
		issue title: newText.
		self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> showAllDueDates [
	dueDateFilter := #all.
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> showChart [
	| canvas statusCounts bars maxCount |
	issues ifEmpty: [
		self inform: 'No issues to display'.
		^ self ].
	
	canvas := RSCanvas new.
	
	statusCounts := Dictionary new.
	#(open inProgress resolved closed) do: [ :status |
		statusCounts at: status put: (issues count: [ :i | i status = status ]) ].
	
	maxCount := statusCounts values max max: 1.
	
	bars := statusCounts associations collect: [ :assoc |
		| bar label |
		bar := RSBox new
			width: 100;
			height: (assoc value / maxCount * 250 max: 10);
			color: (self colorForStatus: assoc key);
			model: assoc;
			yourself.
		
		label := RSLabel new
			text: assoc key asString, String cr, assoc value asString;
			fontSize: 12;
			bold;
			yourself.
		
		RSComposite new
			shapes: { bar. label };
			yourself ].
	
	canvas addAll: bars.
	RSHorizontalLineLayout new gapSize: 20; on: bars.
	canvas @ RSCanvasController.
	
	canvas open setLabel: 'Issue Status Chart'
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> showDueThisWeek [
	dueDateFilter := #week.
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> showDueToday [
	dueDateFilter := #today.
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> toggleHideClosed [
	hideClosedIssues := hideClosedIssues not.
	hideClosedButton label: (hideClosedIssues
		ifTrue: [ 'Show Closed' ]
		ifFalse: [ 'Hide Closed' ]).
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> updateButtonStates [
	"Update filter button labels to show active state"
	showAllButton label: (dueDateFilter = #all 
		ifTrue: [ '• All' ] 
		ifFalse: [ 'All' ]).
	showTodayButton label: (dueDateFilter = #today 
		ifTrue: [ '• Today' ] 
		ifFalse: [ 'Today' ]).
	showWeekButton label: (dueDateFilter = #week 
		ifTrue: [ '• This Week' ] 
		ifFalse: [ 'This Week' ]).
	
	"Update action buttons"
	deleteButton enabled: currentIssue notNil.
	addButton label: (currentIssue 
		ifNil: [ 'Create New Issue' ]
		ifNotNil: [ 'Create New Issue' ])
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> updateDueDate [
    issueList selectedItem ifNotNil: [ :issue |
        issue dueDate: dueDateInput date.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter2 >> updateIssueList [
	| filteredIssues |
	filteredIssues := issues.
	
	"Apply closed filter"
	hideClosedIssues ifTrue: [
		filteredIssues := filteredIssues reject: [ :issue | 
			issue status = #closed ] ].
	
	"Apply due date filter"
	dueDateFilter = #today ifTrue: [
		filteredIssues := filteredIssues select: [ :issue |
			issue dueDate notNil and: [ 
				issue dueDate asDate = Date today ] ] ].
	
	dueDateFilter = #week ifTrue: [
		| today weekFromNow |
		today := Date today.
		weekFromNow := today addDays: 7.
		filteredIssues := filteredIssues select: [ :issue |
			issue dueDate notNil and: [
				issue dueDate asDate between: today and: weekFromNow ] ] ].
	
	issueList items: filteredIssues.
	self updateButtonStates
]
