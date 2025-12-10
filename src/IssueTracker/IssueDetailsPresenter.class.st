Class {
	#name : 'IssueDetailsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleInput',
		'descriptionInput',
		'priorityDropdown',
		'statusDropdown',
		'dueDateInput',
		'startDateInput',
		'durationInput',
		'addButton',
		'deleteButton',
		'isLoadingIssue',
		'lastChangedField',
		'dependenciesList',
		'addDependencyButton',
		'removeDependencyButton',
		'userSetStartDate'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
IssueDetailsPresenter >> addDependency [
	"Override to add auto-save after adding dependency"
	super addDependency.
	IssueRepository uniqueInstance autoSave
]

{ #category : 'initialization' }
IssueDetailsPresenter >> autoCalculateDates [
	"Auto-calculate the appropriate field based on what was last changed"

	| startDate duration dueDate |
	isLoadingIssue ifTrue: [ ^ self ].

	startDate := startDateInput date.
	duration := self selectedDuration.
	dueDate := dueDateInput date.

	"Determine what to calculate based on last changed field"
	lastChangedField = #startDate ifTrue: [ "Start date changed: calculate due date if we have duration"
		(startDate notNil and: [ duration notNil and: [ duration > 0 ] ])
			ifTrue: [
				isLoadingIssue := true.
				dueDateInput date: (startDate asDate addDays: duration).
				self markAsAutoCalculated: dueDateInput.
				isLoadingIssue := false.
				^ self onFieldChanged ] ].

	lastChangedField = #duration ifTrue: [ "If user HASN'T set start date, calculate it from due date"
		((userSetStartDate ifNil: [ false ]) not and: [ 
			 dueDate notNil and: [ duration notNil ] ]) ifTrue: [
			startDateInput date: (dueDate asDate subtractDays: duration).
			^ self onFieldChanged ].

		"Otherwise calculate due date from start date"
		(startDate notNil and: [ duration notNil ]) ifTrue: [
			dueDateInput date: (startDate asDate addDays: duration).
			^ self onFieldChanged ] ].

	lastChangedField = #dueDate ifTrue: [ "Due date changed: calculate start date if we have duration, or duration if we have start"
		(dueDate notNil and: [ duration notNil and: [ duration > 0 ] ])
			ifTrue: [
				isLoadingIssue := true.
				startDateInput date: (dueDate asDate subtractDays: duration).
				self markAsAutoCalculated: startDateInput.
				isLoadingIssue := false.
				^ self onFieldChanged ].

		(dueDate notNil and: [ startDate notNil ]) ifTrue: [
			| calculatedDuration |
			calculatedDuration := dueDate asDate julianDayNumber
			                      - startDate asDate julianDayNumber.
			calculatedDuration := calculatedDuration max: 0.
			isLoadingIssue := true.
			durationInput text: calculatedDuration asString.
			self markAsAutoCalculatedText: durationInput.
			isLoadingIssue := false.
			^ self onFieldChanged ] ].

	"Clear markers if we can't calculate anything"
	self clearAutoCalculatedMarkers.
	self onFieldChanged
]

{ #category : 'initialization' }
IssueDetailsPresenter >> buildLayoutWithDependencies: showDeps [
    "Simplified layout without dependencies section"
    ^ SpBoxLayout newTopToBottom
        spacing: 8;
        add: 'Issue Details' expand: false;
        add: (SpBoxLayout newLeftToRight
            add: 'Title:' width: 80;
            add: titleInput;
            yourself) expand: false;
        add: (SpBoxLayout newLeftToRight
            add: 'Priority:' width: 80;
            add: priorityDropdown width: 120;
            add: 'Status:' width: 80;
            add: statusDropdown width: 120;
            yourself) expand: false;
        add: (SpBoxLayout newLeftToRight
            add: 'Start Date:' width: 80;
            add: startDateInput;
            add: 'Duration:' width: 80;
            add: durationInput width: 100;
            add: 'Due Date:' width: 80;
            add: dueDateInput;
            yourself) expand: false;
        add: 'Description:' expand: false;
        add: descriptionInput height: 80;
        add: (SpBoxLayout newLeftToRight
            spacing: 5;
            add: addButton;
            add: deleteButton;
            yourself) expand: false;
        yourself
]

{ #category : 'initialization' }
IssueDetailsPresenter >> clearAutoCalculatedMarkers [
    "Clear all auto-calculated visual markers"
    startDateInput withAdapterDo: [ :adapterWidget |
        adapterWidget widget 
            borderWidth: 1;
            borderColor: Color gray ].
    dueDateInput withAdapterDo: [ :adapterWidget |
        adapterWidget widget 
            borderWidth: 1;
            borderColor: Color gray ].
    durationInput withAdapterDo: [ :adapterWidget |
        adapterWidget widget 
            borderWidth: 1;
            borderColor: Color gray ]
]

{ #category : 'initialization' }
IssueDetailsPresenter >> clearForm [

	titleInput text: ''.
	descriptionInput text: ''.
	startDateInput date: Date today.
	durationInput text: ''.
	dueDateInput date: nil.
	priorityDropdown selectIndex: 2.
	statusDropdown selectIndex: 1.
	lastChangedField := nil.
	self clearAutoCalculatedMarkers.
	self updateButtonStates
]

{ #category : 'initialization' }
IssueDetailsPresenter >> createNewIssue [

	| issue startDate dueDate duration |
	titleInput text ifEmpty: [
		self inform: 'Please enter a title'.
		^ self ].

	"Get values, handling nil properly"
	startDate := startDateInput date.
	dueDate := dueDateInput date.
	duration := self selectedDuration.

	issue := Issue new
		         title: titleInput text;
		         description: descriptionInput text;
		         priority: priorityDropdown selectedItem;
		         status: statusDropdown selectedItem;
		         yourself.

	"Only set non-nil values"
	startDate ifNotNil: [ issue startDate: startDate ].
	duration ifNotNil: [ issue duration: duration ].
	dueDate ifNotNil: [ issue dueDate: dueDate ].

	IssueRepository uniqueInstance addIssue: issue.

	"Set isLoadingIssue flag to prevent field change events from updating the old current issue"
	isLoadingIssue := true.
	self clearForm.
	isLoadingIssue := false.
	
	"Clear the current issue selection so typing in the form doesn't update the old issue"
	self owner clearCurrentIssue.
	
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
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			add: 'Priority:' width: 80;
			add: priorityDropdown width: 120;
			add: 'Status:' width: 80;
			add: statusDropdown width: 120;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			add: 'Start Date:' width: 80;
			add: startDateInput;
			add: 'Duration:' width: 80;
			add: durationInput width: 100;
			add: 'Due Date:' width: 80;
			add: dueDateInput;
			yourself) expand: false;
		add: 'Description:' expand: false;
		add: descriptionInput height: 80;
		add: (SpBoxLayout newLeftToRight
			spacing: 5;
			add: addButton;
			add: deleteButton;
			yourself) expand: false;
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
IssueDetailsPresenter >> ensureDependenciesInitialized [
    "Initialize dependency buttons only (no list display)"
    addDependencyButton ifNil: [
        addDependencyButton := self newButton
            label: 'Add';
            icon: (self iconNamed: #link);
            action: [ self addDependency ];
            yourself ].
    
    removeDependencyButton ifNil: [
        removeDependencyButton := self newButton
            label: 'Remove';
            icon: (self iconNamed: #delete);
            action: [ self removeDependencySelected ];
            yourself ]
]

{ #category : 'initialization' }
IssueDetailsPresenter >> hasCurrentIssue [
	^ self owner hasCurrentIssue
]

{ #category : 'initialization' }
IssueDetailsPresenter >> initializePresenters [

	isLoadingIssue := false.
	lastChangedField := nil.
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

	"Start Date - default to today"
	startDateInput := self instantiate: SpDatePresenter.
	startDateInput date: Date today.
	startDateInput whenDateChanged: [
		userSetStartDate := true.
		lastChangedField := #startDate.
		self autoCalculateDates ].
	"Duration (in days) - use text input instead"
	durationInput := self newTextInput
		                 placeholder: 'Days';
		                 yourself.
	durationInput whenTextChangedDo: [
		lastChangedField := #duration.
		self autoCalculateDates ].
	"Due Date"
	dueDateInput := self instantiate: SpDatePresenter.
	dueDateInput whenDateChanged: [
		lastChangedField := #dueDate.
		self autoCalculateDates ].
	"Priority"
	priorityDropdown := self newDropList
		                    items: #( low medium high critical );
		                    selectIndex: 2;
		                    yourself.
	priorityDropdown whenSelectedItemChangedDo: [ self onFieldChanged ].
	"Status"
	statusDropdown := self newDropList
		                  items: #( open inProgress resolved closed milestone );
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

	"Dependencies UI components"
	dependenciesList := self newTable.
	dependenciesList
		addColumn: (SpStringTableColumn
				 title: 'Dependencies'
				 evaluated: [ :anIssue | anIssue title ]) yourself;
		beResizable
]

{ #category : 'initialization' }
IssueDetailsPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Issue Tracker - Gantt View';
		initialExtent: 1200 @ 800
]

{ #category : 'initialization' }
IssueDetailsPresenter >> loadDependencies: anIssue [
    "Dependencies are managed via dialog, not displayed in form"
    ^ self
]

{ #category : 'initialization' }
IssueDetailsPresenter >> loadIssue: anIssue [

	isLoadingIssue := true.
	lastChangedField := nil.
	anIssue ifNotNil: [
		titleInput text: anIssue title.
		descriptionInput text: (anIssue description ifNil: [ '' ]).
		statusDropdown selectItem: anIssue status.
		priorityDropdown selectItem: anIssue priority.
		startDateInput date: anIssue startDate.
		userSetStartDate := anIssue startDate notNil. 
		durationInput text:
			(anIssue duration ifNil: [ '' ] ifNotNil: [ :d | d asString ]).
		dueDateInput date: anIssue dueDate ].
	self clearAutoCalculatedMarkers.
	isLoadingIssue := false.
	self updateButtonStates
]

{ #category : 'initialization' }
IssueDetailsPresenter >> markAsAutoCalculated: aDatePresenter [
    "Mark a date presenter as auto-calculated with a green border"
    aDatePresenter withAdapterDo: [ :adapterWidget |
        adapterWidget widget 
            borderWidth: 2;
            borderColor: (Color green alpha: 0.6) ]
]

{ #category : 'initialization' }
IssueDetailsPresenter >> markAsAutoCalculatedText: aTextInput [
    "Mark a text input as auto-calculated with a green border"
    aTextInput withAdapterDo: [ :adapterWidget |
        adapterWidget widget 
            borderWidth: 2;
            borderColor: (Color green alpha: 0.6) ]
]

{ #category : 'initialization' }
IssueDetailsPresenter >> onFieldChanged [
	"Notify owner when fields change"
	isLoadingIssue ifTrue: [ ^ self ].
	self owner fieldChanged
]

{ #category : 'initialization' }
IssueDetailsPresenter >> openDependencyDialog [
	| currentIssue |
	currentIssue := self owner currentIssue.
	currentIssue ifNil: [ 
		^ self inform: 'Please select an issue first' ].
	
	IssueDependencyDialog openFor: currentIssue.
	"Refresh after dialog closes"
	self owner issueListChanged
]

{ #category : 'initialization' }
IssueDetailsPresenter >> removeDependency [
	"Remove selected dependency (kept for backward compatibility)"
	| currentIssue selectedDep |
	currentIssue := self owner currentIssue.
	currentIssue ifNil: [ ^ self ].
	
	"Try to get the selected item from table"
	selectedDep := dependenciesList selection selectedItem.
	
	selectedDep ifNil: [ 
		^ self inform: 'Please select a dependency to remove' ].
	
	self removeDependencyDirect: selectedDep
]

{ #category : 'initialization' }
IssueDetailsPresenter >> removeDependencyDirect: aDependency [
	"Override to add auto-save after removing dependency"
	super removeDependencyDirect: aDependency.
	IssueRepository uniqueInstance autoSave
]

{ #category : 'initialization' }
IssueDetailsPresenter >> removeDependencySelected [
	"Remove selected dependency from table"
	| currentIssue selectedDep |
	currentIssue := self owner currentIssue.
	currentIssue ifNil: [ ^ self ].
	
	"Try to get the selected item from table"
	selectedDep := dependenciesList selection selectedItem.
	
	selectedDep ifNil: [ 
		^ self inform: 'Please select a dependency to remove' ].
	
	self removeDependencyDirect: selectedDep
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedDueDate [
	^ dueDateInput date
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedDuration [
    | text |
    text := durationInput text trimBoth.
    text ifEmpty: [ ^ nil ].
    ^ [ text asNumber ] on: Error do: [ nil ]
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedPriority [
	^ priorityDropdown selectedItem
]

{ #category : 'initialization' }
IssueDetailsPresenter >> selectedStartDate [
    ^ startDateInput date
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

{ #category : 'initialization' }
IssueDetailsPresenter >> updateDependenciesVisibility [
    "Dependencies are now managed via dialog only, not shown in form"
    self layout: (self buildLayoutWithDependencies: false)
]

{ #category : 'initialization' }
IssueDetailsPresenter >> updateIssue [
	"Override to add auto-save after updating"
	| result |
	result := super updateIssue.
	IssueRepository uniqueInstance autoSave.
	^ result
]
