Class {
	#name : 'IssueTrackerGanttPresenter',
	#superclass : 'SpPresenter',
	#traits : 'TPersistenceMenuTrait',
	#classTraits : 'TPersistenceMenuTrait classTrait',
	#instVars : [
		'toolbar',
		'ganttCanvas',
		'detailsForm',
		'issues',
		'currentIssue',
		'moveUpButton',
		'moveDownButton',
		'viewSwitchButton',
		'updateTask',
		'ganttBuilder',
		'issueManager'
	],
	#category : 'IssueTracker-UI',
	#package : 'IssueTracker',
	#tag : 'UI'
}

{ #category : 'instance creation' }
IssueTrackerGanttPresenter class >> open [
	<script>
	^ self new open
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> addDependencyTo: anIssue [
	"Add a single dependency with immediate chart update"
	| validCandidates selectedIssue |
	
	"Use the manager to find valid candidates"
	validCandidates := issueManager availableDependenciesFor: anIssue.
	
	validCandidates ifEmpty: [ 
		^ self inform: 'No available issues to add as dependencies' ].
	
	selectedIssue := UIManager default 
		chooseFrom: (validCandidates collect: #title)
		values: validCandidates
		title: 'Select issue that "', anIssue title, '" depends on:'.
	
	selectedIssue ifNotNil: [
		(issueManager addDependency: selectedIssue to: anIssue) ifTrue: [
			"Update the Gantt chart to show the new dependency arrow"
			self updateGanttChart.
			
			"Update details form if this is the current issue"
			currentIssue = anIssue ifTrue: [
				detailsForm ensureDependenciesInitialized.
				detailsForm loadDependencies: anIssue ].
			
			self inform: 'Dependency added successfully'
		] ifFalse: [
			self inform: 'Failed to add dependency' ] ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> buildGanttChart [
	ganttCanvas script: [ :rsCanvas | self buildGanttOn: rsCanvas ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> buildGanttOn: rsCanvas [
	"Simplified method that delegates to GanttChartBuilder"
	| filteredIssues |
	
	"Apply filters"
	filteredIssues := self getFilteredIssues.
	
	"Create and configure builder"
	ganttBuilder := IssueGanttChartBuilder new.
	ganttBuilder canvas: rsCanvas.
	ganttBuilder issues: filteredIssues.
	
	"Set up callbacks"
	ganttBuilder onIssueClick: [ :issue | self onIssueSelected: issue ].
	ganttBuilder onIssueRightClick: [ :issue :evt | self showContextMenuFor: issue at: evt ].
	
	"Build the chart"
	^ ganttBuilder build
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> clearCurrentIssue [
	"Clear the current issue selection"
	currentIssue := nil
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> currentIssue [
	^ currentIssue

]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom
        spacing: 0;
        add: (SpBoxLayout newLeftToRight
            spacing: 5;
            add: toolbar;
            add: viewSwitchButton width: 100;
            yourself) expand: false;
        add: (SpBoxLayout newLeftToRight
            spacing: 5;
            add: (SpPanedLayout newTopToBottom
                positionOfSlider: 0.6;
                add: ganttCanvas;
                add: detailsForm;
                yourself);
            add: (SpBoxLayout newTopToBottom
                spacing: 5;
                add: moveUpButton expand: false;
                add: moveDownButton expand: false;
                addLast: '';  "spacer"
                yourself) width: 100;
            yourself);
        yourself
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> deleteCurrentIssue [
	"Delete the currently selected issue"
	
	currentIssue ifNil: [ ^ self ].
	
	(self confirm: 'Delete issue "', currentIssue title, '"?') ifTrue: [
		issueManager deleteIssue: currentIssue.
		self clearCurrentIssue.
		self issueListChanged ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> fieldChanged [
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
		self updateGanttChart.
		detailsForm ensureDependenciesInitialized.
		detailsForm loadDependencies: issue ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> filterChanged [
	self updateGanttChart
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> getFilteredIssues [
	"Get issues filtered by current toolbar settings"
	| filter |
	
	filter := IssueFilter fromToolbar: toolbar.
	^ filter applyTo: issueManager allIssues
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> hasCurrentIssue [
	^ currentIssue notNil
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> initializePresenters [

	issueManager := IssueManager default.
	issues := issueManager allIssues.
	currentIssue := nil.

	toolbar := self instantiate: IssueToolbarPresenter.
	detailsForm := self instantiate: IssueDetailsPresenter.
	ganttCanvas := self instantiate: SpRoassalPresenter.

	"Add view switch button"
	viewSwitchButton := self newButton
		                    label: 'Table View';
		                    icon: (self iconNamed: #smallConfiguration);
		                    help: 'Switch to table view';
		                    action: [ self switchToTableView ];
		                    yourself.

	"Add reordering buttons"
	moveUpButton := self newButton
		                icon: (self iconNamed: #up);
		                help: 'Move selected issue up in order';
		                action: [ self moveIssueUp ];
		                enabled: false;
		                yourself.

	moveDownButton := self newButton
		                  icon: (self iconNamed: #down);
		                  help: 'Move selected issue down in order';
		                  action: [ self moveIssueDown ];
		                  enabled: false;
		                  yourself.
	toolbar refreshStatus.
	self buildGanttChart
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Issue Tracker - Gantt View';
		initialExtent: 1200 @ 800.

]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> issueListChanged [
      issues := issueManager allIssues.
      self updateGanttChart updateMoveButtonsState.
      toolbar refreshStatus.  "refresh the status label"

]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> manageDependenciesFor: anIssue [
	"Open dependency dialog with callback for real-time updates"
	| dialog |
	dialog := IssueDependencyDialog new.
	dialog issue: anIssue.
	
	"Set callback to update chart immediately when dependencies change"
	dialog onDependencyChanged: [ 
		self updateGanttChart.
		"Update details form if this is the current issue"
		currentIssue = anIssue ifTrue: [
			detailsForm ensureDependenciesInitialized.
			detailsForm loadDependencies: anIssue ] ].
	
	dialog open
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> moveIssueDown [
	"Move the selected issue down in the list"
	
	currentIssue ifNil: [ ^ self ].
	
	(issueManager moveIssueDown: currentIssue) ifTrue: [
		self updateGanttChart.
		self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> moveIssueUp [
	"Move the selected issue up in the list"
	
	currentIssue ifNil: [ ^ self ].
	
	(issueManager moveIssueUp: currentIssue) ifTrue: [
		self updateGanttChart.
		self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> onIssueSelected: anIssue [
    currentIssue := anIssue.
    detailsForm loadIssue: anIssue.
    detailsForm ensureDependenciesInitialized.
    detailsForm loadDependencies: anIssue.
    self updateMoveButtonsState
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> showContextMenuFor: anIssue at: evt [
	| menu |
	menu := SpMenuPresenter new.
	
	"Add dependency option"
	menu addItem: [ :item |
		item 
			name: 'Add Dependency...';
			icon: (self iconNamed: #link);
			action: [ self addDependencyTo: anIssue ] ].
	
	"Manage dependencies (if any exist)"
	anIssue hasDependencies ifTrue: [
		menu addItem: [ :item |
			item 
				name: 'Manage Dependencies (', anIssue dependencies size asString, ')';
				icon: (self iconNamed: #edit);
				action: [ self manageDependenciesFor: anIssue ] ] ].
	
	menu addItem: [ :item |
		item name: ''; enabled: false ]. "Separator"
	
	"Delete option"
	menu addItem: [ :item |
		item 
			name: 'Delete Issue';
			icon: (self iconNamed: #delete);
			action: [ 
				currentIssue := anIssue.
				self deleteCurrentIssue ] ].
	
	menu openWithSpecAtPointer
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> showEmptyMessageOn: rsCanvas [
	| label |
	label := RSLabel new
		text: 'No issues with dates to display. Create an issue with start/due dates.';
		fontSize: 14;
		yourself.
	rsCanvas add: label.
	^ rsCanvas
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> switchToTableView [
    "Close current window and open table view at same position"
    | tablePresenter currentPosition |
    currentPosition := self window adapter widget position.
    tablePresenter := IssueTrackerTablePresenter new.
    tablePresenter open.
    tablePresenter window adapter widget position: currentPosition.
    self window close
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> updateGanttChart [
	"Rebuild the Gantt chart"
	self buildGanttChart
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> updateMoveButtonsState [
	"Enable/disable move buttons based on selection position"
	
	currentIssue ifNil: [
		moveUpButton enabled: false.
		moveDownButton enabled: false.
		^ self ].
	
	moveUpButton enabled: (issueManager canMoveUp: currentIssue).
	moveDownButton enabled: (issueManager canMoveDown: currentIssue)
]
