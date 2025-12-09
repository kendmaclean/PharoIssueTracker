"
why use self instantiate?

When you use self instantiate: IssueToolbarPresenter (or any sub-presenter), Spec2 automatically sets the owner of that sub-presenter to be the parent presenter that instantiated it.

""self owner"" refers to the parent presenter
"
Class {
	#name : 'IssueTrackerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'toolbar',
		'issueList',
		'detailsForm',
		'issues',
		'currentIssue',
		'moveUpButton',
		'moveDownButton',
		'viewSwitchButton'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssueTrackerPresenter class >> open [
	<script>
	^ self new open
]

{ #category : 'initialization' }
IssueTrackerPresenter >> buildContextMenu [
    | menu selectedIssue |
    
    "Get the currently selected issue"
    selectedIssue := issueList selection selectedItem.
    selectedIssue ifNil: [ ^ nil ].  "No menu if nothing selected"
    
    menu := self newMenu.
    
    menu addItem: [ :item |
        item
            name: 'Manage Dependencies...';
            icon: (self iconNamed: #link);
            action: [ self openDependencyDialogFor: selectedIssue ] ].
    
    menu addItem: [ :item |
        item
            name: 'Delete Issue';
            icon: (self iconNamed: #delete);
            action: [ self deleteIssue: selectedIssue ] ].
    
    ^ menu
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
                positionOfSlider: 0.6;  "Same as Gantt view"
                add: issueList;
                add: detailsForm;
                yourself);
            add: (SpBoxLayout newTopToBottom
                spacing: 5;
                add: moveUpButton expand: false;
                add: moveDownButton expand: false;
                addLast: '';  "spacer"
                yourself)
            width: 50;
            yourself);
        yourself
]

{ #category : 'initialization' }
IssueTrackerPresenter >> deleteCurrentIssue [
	currentIssue ifNotNil: [ :issue |
		(self confirm: 'Delete issue: ', issue title, '?') ifTrue: [
			IssueRepository uniqueInstance removeIssue: issue.
			issues := IssueRepository uniqueInstance allIssues.
			issueList unselectAll.
			detailsForm clearForm.
			currentIssue := nil.
			self updateIssueList ] ]
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
IssueTrackerPresenter >> fieldChanged [
    "Update the currently selected issue when fields change"
    currentIssue ifNotNil: [ :issue |
        issue title: detailsForm titleText.
        issue description: detailsForm descriptionText.
        issue status: detailsForm selectedStatus.
        issue priority: detailsForm selectedPriority.
        issue startDate: detailsForm selectedStartDate.
        issue duration: detailsForm selectedDuration.
        issue dueDate: detailsForm selectedDueDate.
        self updateIssueList ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> filterChanged [
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> hasCurrentIssue [
	^ currentIssue notNil
]

{ #category : 'initialization' }
IssueTrackerPresenter >> initializePresenters [

	issues := IssueRepository uniqueInstance allIssues.
	currentIssue := nil.

	toolbar := self instantiate: IssueToolbarPresenter.
	issueList := self newTable.
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
		                label: '↑';
		                icon: (self iconNamed: #up);
		                help: 'Move issue up';
		                action: [ self moveIssueUp ];
		                yourself.

	moveDownButton := self newButton
		                  label: '↓';
		                  icon: (self iconNamed: #down);
		                  help: 'Move issue down';
		                  action: [ self moveIssueDown ].

	issueList
		addColumn: (SpStringTableColumn
				 title: 'Title'
				 evaluated: [ :anIssue | anIssue title ]) yourself;
		addColumn: ((SpStringTableColumn
				  title: 'Priority'
				  evaluated: [ :anIssue | anIssue priority asString ])
				 width: 100;
				 yourself);
		addColumn: ((SpStringTableColumn
				  title: 'Status'
				  evaluated: [ :anIssue | anIssue status asString ])
				 width: 100;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'Due Date' evaluated: [ :anIssue |
					  anIssue dueDate
						  ifNil: [ '' ]
						  ifNotNil: [ :date | date asDate asString ] ])
				 width: 120;
				 yourself);
		items: issues;
		beResizable;
		contextMenu: [ self buildContextMenu ].

	issueList whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :selectedIssue |
			currentIssue := selectedIssue.
			detailsForm loadIssue: selectedIssue.
			self updateMoveButtonsState ] ].

	self updateMoveButtonsState
]

{ #category : 'initialization' }
IssueTrackerPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Issue Tracker';
		initialExtent: 1200 @ 800
]

{ #category : 'initialization' }
IssueTrackerPresenter >> issueListChanged [
    "Refresh the issue list from the repository"
    issues := IssueRepository uniqueInstance allIssues.
    issueList items: issues.
    self updateMoveButtonsState
]

{ #category : 'initialization' }
IssueTrackerPresenter >> moveIssueDown [
    | repository currentIndex itemToMove |
    currentIssue ifNil: [ ^ self ].
    
    itemToMove := currentIssue.
    repository := IssueRepository uniqueInstance.
    currentIndex := repository allIssues indexOf: itemToMove.
    
    currentIndex < repository allIssues size ifTrue: [
        "Swap directly in the repository's internal collection"
        repository swapIssueAt: currentIndex with: currentIndex + 1.
        
        "Refresh the display"
        issueList items: repository allIssues.
        currentIssue := itemToMove.
        issueList selectIndex: currentIndex + 1.
        self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> moveIssueUp [
    | repository currentIndex itemToMove |
    currentIssue ifNil: [ ^ self ].
    
    itemToMove := currentIssue.
    repository := IssueRepository uniqueInstance.
    currentIndex := repository allIssues indexOf: itemToMove.
    
    Transcript show: 'Before move: currentIssue = ', itemToMove title; cr.
    Transcript show: 'Current index: ', currentIndex asString; cr.
    
    currentIndex > 1 ifTrue: [
        "Swap directly in the repository's internal collection"
        repository swapIssueAt: currentIndex with: currentIndex - 1.
        
        "Refresh the display"
        issueList items: repository allIssues.
        currentIssue := itemToMove.
        issueList selectIndex: currentIndex - 1.
        self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onIssueSelected: anIssue [
	currentIssue := anIssue.
	detailsForm loadIssue: anIssue
]

{ #category : 'initialization' }
IssueTrackerPresenter >> openDependencyDialogFor: anIssue [
    "Open the dependency dialog for the given issue"
    IssueDependencyDialog openFor: anIssue.
    "Refresh after dialog closes"
    self issueListChanged
]

{ #category : 'initialization' }
IssueTrackerPresenter >> reorderIssue: draggedIssue dropItem: targetIssue [
    "Reorder the issue in the repository when dropped on another issue"
    | allIssues dragIndex targetIndex |
    
    allIssues := IssueRepository uniqueInstance allIssues.
    dragIndex := allIssues indexOf: draggedIssue.
    targetIndex := allIssues indexOf: targetIssue.
    
    "Remove from old position and insert at new position"
    allIssues removeAt: dragIndex.
    allIssues add: draggedIssue beforeIndex: targetIndex.
    
    "Update the display"
    issueList items: allIssues.
    
    "Keep selection"
    issueList selectItem: draggedIssue
]

{ #category : 'initialization' }
IssueTrackerPresenter >> switchToGanttView [
    "Close current window and open Gantt view"
    | ganttPresenter |
    ganttPresenter := IssueTrackerGanttPresenter new.
    ganttPresenter open.
    self window close
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateIssueList [
	| filteredIssues |
	filteredIssues := issues.
	
	"Apply closed filter"
	toolbar hideClosedIssues ifTrue: [
		filteredIssues := filteredIssues reject: [ :issue | 
			issue status = #closed ] ].
	
	"Apply due date filter"
	toolbar dueDateFilter = #today ifTrue: [
		| today |
		today := Date today.
		filteredIssues := filteredIssues select: [ :issue |
			| startDate endDate |
			startDate := issue computedStartDate.
			endDate := issue computedDueDate.
			startDate notNil and: [ endDate notNil and: [
				"Issue is active today if today falls between start and end dates"
				today between: startDate asDate and: endDate asDate ] ] ] ].
	
	toolbar dueDateFilter = #week ifTrue: [
		| today weekFromNow |
		today := Date today.
		weekFromNow := today addDays: 7.
		filteredIssues := filteredIssues select: [ :issue |
			| startDate endDate |
			startDate := issue computedStartDate.
			endDate := issue computedDueDate.
			startDate notNil and: [ endDate notNil and: [
				"Issue is active this week if it overlaps with the week period"
				(startDate asDate <= weekFromNow) and: [ endDate asDate >= today ] ] ] ] ].
	
	issueList items: filteredIssues
]

{ #category : 'initialization' }
IssueTrackerPresenter >> updateMoveButtonsState [
    "Enable/disable move buttons based on selection position"
    | allIssues currentIndex |
    
    currentIssue ifNil: [
        moveUpButton enabled: false.
        moveDownButton enabled: false.
        ^ self ].
    
    allIssues := IssueRepository uniqueInstance allIssues.
    currentIndex := allIssues indexOf: currentIssue.
    
    moveUpButton enabled: currentIndex > 1.
    moveDownButton enabled: currentIndex < allIssues size
]
