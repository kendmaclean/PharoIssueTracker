"
why use self instantiate?

When you use self instantiate: IssueToolbarPresenter (or any sub-presenter), Spec2 automatically sets the owner of that sub-presenter to be the parent presenter that instantiated it.

""self owner"" refers to the parent presenter
"
Class {
	#name : 'IssueTrackerPresenter',
	#superclass : 'SpPresenter',
	#traits : 'TPersistenceMenuTrait',
	#classTraits : 'TPersistenceMenuTrait classTrait',
	#instVars : [
		'toolbar',
		'issueList',
		'detailsForm',
		'issues',
		'currentIssue',
		'moveUpButton',
		'moveDownButton',
		'viewSwitchButton',
		'updateTask',
		'issueManager'
	],
	#category : 'IssueTracker-UI',
	#package : 'IssueTracker',
	#tag : 'UI'
}

{ #category : 'instance creation' }
IssueTrackerPresenter class >> open [
	<script>
	^ self new open
]

{ #category : 'initialization' }
IssueTrackerPresenter >> clearCurrentIssue [
	"Clear the current issue selection"
	currentIssue := nil
]

{ #category : 'initialization' }
IssueTrackerPresenter >> currentIssue [
    ^ currentIssue
]

{ #category : 'initialization' }
IssueTrackerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 5;
				   add: toolbar;
				   add: viewSwitchButton width: 100;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 5;
				   add: (SpPanedLayout newTopToBottom
						    positionOfSlider: 0.6;
						    add: issueList;
						    add: detailsForm;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    spacing: 5;
						    add: moveUpButton expand: false;
						    add: moveDownButton expand: false;
						    addLast: '';
						    yourself)
				   width: 50;
				   yourself);
		  yourself
]

{ #category : 'initialization' }
IssueTrackerPresenter >> deleteCurrentIssue [
    "Delete the currently selected issue"
    
    currentIssue ifNil: [ ^ self ].
    
    (self confirm: 'Delete issue: "', currentIssue title, '"?') ifTrue: [
        issueManager deleteIssue: currentIssue.
        self clearCurrentIssue.
        detailsForm clearForm.
        self issueListChanged ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> deleteIssue: anIssue [
    "Delete the given issue after confirmation"
    | confirm |
    confirm := UIManager default 
        confirm: 'Are you sure you want to delete "', anIssue title, '"?'
        label: 'Confirm Delete'.
    
    confirm ifTrue: [
        IssueRepository uniqueInstance removeIssue: anIssue.
        currentIssue := nil.
        detailsForm loadIssue: nil.  "Use loadIssue: nil instead of clear"
        self issueListChanged ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> deleteSelectedIssue [
	"Override to add auto-save after deleting issue"
	super deleteSelectedIssue.
	IssueRepository uniqueInstance autoSave
]

{ #category : 'initialization' }
IssueTrackerPresenter >> fieldChanged [
    "Update the currently selected issue when fields change"
    currentIssue ifNotNil: [ :issue |
        issueManager updateIssue: issue with: (Dictionary new
            at: #title put: detailsForm titleText;
            at: #description put: detailsForm descriptionText;
            at: #status put: detailsForm selectedStatus;
            at: #priority put: detailsForm selectedPriority;
            at: #startDate put: detailsForm selectedStartDate;
            at: #duration put: detailsForm selectedDuration;
            at: #dueDate put: detailsForm selectedDueDate;
            yourself).
        
        "Schedule debounced update"
        updateTask ifNotNil: [ updateTask terminate ].
        updateTask := [ 
            300 milliSeconds wait.
            self updateIssueList.
            updateTask := nil 
        ] forkAt: Processor userBackgroundPriority ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> filterChanged [
	"Same data, filters changed - reapply filters to the current issue list"

	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> getFilteredIssues [
	"Get issues filtered by current toolbar settings"
	| filter |
	
	filter := IssueFilter fromToolbar: toolbar.
	^ filter applyTo: issues
]

{ #category : 'initialization' }
IssueTrackerPresenter >> hasCurrentIssue [
	^ currentIssue notNil
]

{ #category : 'initialization' }
IssueTrackerPresenter >> initializePresenters [

	issueManager := IssueManager default.
	issues := issueManager allIssues.
	currentIssue := nil.

	toolbar := self instantiate: IssueToolbarPresenter.
	issueList := self instantiate: IssueListPresenter.
	detailsForm := self instantiate: IssueDetailsPresenter.

	"Add view switch button"
	viewSwitchButton := self newButton
		                    label: 'Gantt View';
		                    icon: (self iconNamed: #glamorousTable);
		                    help: 'Switch to Gantt chart view';
		                    action: [ self switchToGanttView ];
		                    yourself.

	"Add reordering buttons"
	moveUpButton := self newButton
		                icon: (self iconNamed: #up);
		                help: 'Move selected issue up in order';
		                action: [ self moveIssueUp ];
		                yourself.

	moveDownButton := self newButton
		                  icon: (self iconNamed: #down);
		                  help: 'Move selected issue down in order';
		                  action: [ self moveIssueDown ].

	issueList items: issues.
	toolbar refreshStatus.
	self updateMoveButtonsState
]

{ #category : 'initialization' }
IssueTrackerPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Issue Tracker';
		initialExtent: 1200 @ 800.

]

{ #category : 'initialization' }
IssueTrackerPresenter >> issueListChanged [
      issues := issueManager allIssues.
      self updateIssueList. 
      self updateMoveButtonsState.
      toolbar refreshStatus.  "refresh the status label"

]

{ #category : 'initialization' }
IssueTrackerPresenter >> moveIssueDown [

	| repository currentIndex itemToMove allIssues |
	currentIssue ifNil: [ ^ self ].

	itemToMove := currentIssue.
	repository := IssueRepository uniqueInstance.
	allIssues := repository allIssues.
	currentIndex := allIssues indexOf: itemToMove.

	currentIndex < allIssues size ifTrue: [ 
		"Swap directly in the repository's internal collection"
		repository swapIssueAt: currentIndex with: currentIndex + 1.
		
		"Auto-save the change"
		repository autoSave.

		"Refresh the display"
		issueList items: repository allIssues.
		currentIssue := itemToMove.
		issueList selectItem: itemToMove.
		self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> moveIssueUp [

	| repository currentIndex itemToMove allIssues |
	currentIssue ifNil: [ ^ self ].

	itemToMove := currentIssue.
	repository := IssueRepository uniqueInstance.
	allIssues := repository allIssues.
	currentIndex := allIssues indexOf: itemToMove.

	currentIndex > 1 ifTrue: [ 
		"Swap directly in the repository's internal collection"
		repository swapIssueAt: currentIndex with: currentIndex - 1.
		
		"Auto-save the change"
		repository autoSave.

		"Refresh the display"
		issueList items: repository allIssues.
		currentIssue := itemToMove.
		issueList selectItem: itemToMove.
		self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onIssueSelected: anIssue [

	currentIssue := anIssue.
	detailsForm loadIssue: anIssue.
	self updateMoveButtonsState
]

{ #category : 'initialization' }
IssueTrackerPresenter >> openDependencyDialogFor: anIssue [
    "Open the dependency dialog for the given issue"
    IssueDependencyDialog openFor: anIssue.
    "Refresh after dialog closes"
    self issueListChanged
]

{ #category : 'initialization' }
IssueTrackerPresenter >> switchToGanttView [
    "Close current window and open Gantt view at same position"
    | ganttPresenter currentPosition |
    currentPosition := self window adapter widget position.
    ganttPresenter := IssueTrackerGanttPresenter new.
    ganttPresenter open.
    ganttPresenter window adapter widget position: currentPosition.
    self window close
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateIssueList [
	"UPdate the UI - ipdate the displayed issue list with current filters"

	issueList items: self getFilteredIssues
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateMoveButtonsState [
    "Enable/disable move buttons based on selection position"
    
    currentIssue ifNil: [
        moveUpButton enabled: false.
        moveDownButton enabled: false.
        ^ self ].
    
    moveUpButton enabled: (issueManager canMoveUp: currentIssue).
    moveDownButton enabled: (issueManager canMoveDown: currentIssue)
]
