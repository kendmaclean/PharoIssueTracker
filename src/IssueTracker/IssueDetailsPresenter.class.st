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
		'removeDependencyButton'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
IssueDetailsPresenter >> addDependency [
	| validCandidates currentIssue selectedIssue |
	currentIssue := self owner currentIssue.
	currentIssue ifNil: [ ^ self inform: 'Please select an issue first' ].

	"Use the Handler to find valid candidates from the repository"
	validCandidates := currentIssue dependencyHandler 
		availableDependenciesIn: IssueRepository uniqueInstance allIssues.

	validCandidates ifEmpty: [ ^ self inform: 'No available issues to add as dependencies' ].

	selectedIssue := UIManager default 
		chooseFrom: (validCandidates collect: #title)
		values: validCandidates
		title: 'Select issue this depends on:'.

	selectedIssue ifNotNil: [
		[ 
		  currentIssue addDependency: selectedIssue.
		  dependenciesList items: currentIssue dependencies.
		  self updateDependenciesVisibility.
		  self owner issueListChanged 
		] on: Error do: [ :ex | self inform: ex messageText ] 
	]
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
    lastChangedField = #startDate ifTrue: [
        "Start date changed: calculate due date if we have duration"
        (startDate notNil and: [ duration notNil and: [ duration > 0 ] ]) ifTrue: [
            isLoadingIssue := true.
            dueDateInput date: (startDate asDate addDays: duration).
            self markAsAutoCalculated: dueDateInput.
            isLoadingIssue := false.
            ^ self onFieldChanged ] ].
    
    lastChangedField = #duration ifTrue: [
        "Duration changed: prefer calculating due date from start, but if no start, calculate start from due"
        (startDate notNil and: [ duration notNil and: [ duration > 0 ] ]) ifTrue: [
            isLoadingIssue := true.
            dueDateInput date: (startDate asDate addDays: duration).
            self markAsAutoCalculated: dueDateInput.
            isLoadingIssue := false.
            ^ self onFieldChanged ].
        
        (dueDate notNil and: [ duration notNil and: [ duration > 0 ] ]) ifTrue: [
            isLoadingIssue := true.
            startDateInput date: (dueDate asDate subtractDays: duration).
            self markAsAutoCalculated: startDateInput.
            isLoadingIssue := false.
            ^ self onFieldChanged ] ].
    
    lastChangedField = #dueDate ifTrue: [
        "Due date changed: calculate start date if we have duration, or duration if we have start"
        (dueDate notNil and: [ duration notNil and: [ duration > 0 ] ]) ifTrue: [
            isLoadingIssue := true.
            startDateInput date: (dueDate asDate subtractDays: duration).
            self markAsAutoCalculated: startDateInput.
            isLoadingIssue := false.
            ^ self onFieldChanged ].
        
        (dueDate notNil and: [ startDate notNil ]) ifTrue: [
            | calculatedDuration |
            calculatedDuration := dueDate asDate julianDayNumber - startDate asDate julianDayNumber.
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
	| boxLayout dependenciesSection |
	boxLayout := SpBoxLayout newTopToBottom
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
				              yourself)
		             expand: false;
		             add: (SpBoxLayout newLeftToRight
				              add: 'Start Date:' width: 80;
				              add: startDateInput;
				              add: 'Duration:' width: 80;
				              add: durationInput width: 100;
				              add: 'Due Date:' width: 80;
				              add: dueDateInput;
				              yourself)
		             expand: false;
		             add: 'Description:' expand: false;
		             add: descriptionInput height: 80;
		             yourself.

	"Conditionally add dependencies section with buttons on the right"
	showDeps ifTrue: [
		dependenciesSection := SpBoxLayout newLeftToRight
			spacing: 8;
			add: (SpBoxLayout newTopToBottom
				spacing: 4;
				add: 'Dependencies (this issue depends on):' expand: false;
				add: dependenciesList;
				yourself);
			add: (SpBoxLayout newTopToBottom
				spacing: 5;
				add: addDependencyButton expand: false;
				add: removeDependencyButton expand: false;
				addLast: '' "spacer";
				yourself) width: 140;
			yourself.
		
		boxLayout add: dependenciesSection height: 150 ].

	"Add dependency buttons separately if no dependencies shown"
	showDeps ifFalse: [
		boxLayout
			add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: addDependencyButton;
				yourself)
			expand: false ].

	boxLayout
		add: (SpBoxLayout newLeftToRight
			spacing: 5;
			add: addButton;
			add: deleteButton;
			yourself)
		expand: false.

	^ boxLayout
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
IssueDetailsPresenter >> loadDependencies: anIssue [
    anIssue ifNil: [ 
        dependenciesList items: #().
        self updateDependenciesVisibility.
        ^ self ].
    
    dependenciesList items: anIssue dependencies.
    self updateDependenciesVisibility
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
		durationInput text: (anIssue duration 
			ifNil: [ '' ]
			ifNotNil: [ :d | d asString ]).
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
	"Remove a dependency directly"
	| currentIssue |
	currentIssue := self owner currentIssue.
	currentIssue ifNil: [ ^ self ].
	
	currentIssue removeDependency: aDependency.
	dependenciesList items: currentIssue dependencies.
	self updateDependenciesVisibility.
	self owner issueListChanged
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
    "Rebuild layout with or without dependencies section"
    | currentIssue hasDeps |
    
    currentIssue := self owner currentIssue.
    hasDeps := currentIssue notNil and: [ currentIssue hasDependencies ].
    
    self layout: (self buildLayoutWithDependencies: hasDeps)
]
