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
		'ganttBuilder'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
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
	
	"Use the Handler to find valid candidates from the repository"
	validCandidates := anIssue dependencyHandler   
		availableDependenciesIn: IssueRepository uniqueInstance allIssues.
	
	validCandidates ifEmpty: [   
		^ self inform: 'No available issues to add as dependencies' ].
	
	selectedIssue := UIManager default   
		chooseFrom: (validCandidates collect: #title)
		values: validCandidates
		title: 'Select issue that "', anIssue title, '" depends on:'.
	
	selectedIssue ifNotNil: [
		[   
			anIssue addDependency: selectedIssue.
			
			"NEW: Auto-save the changes"
			IssueRepository uniqueInstance autoSave.
			
			"Update the Gantt chart to show the new dependency arrow"
			self updateGanttChart.
			
			"Update details form if this is the current issue"
			currentIssue = anIssue ifTrue: [
				detailsForm ensureDependenciesInitialized.
				detailsForm loadDependencies: anIssue ].
			
			self inform: 'Dependency added successfully'
		] on: Error do: [ :ex | self inform: ex messageText ] ]
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
	ganttBuilder := GanttChartBuilder new.
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
	currentIssue ifNotNil: [ :issue |
		(self confirm: 'Delete issue: ', issue title, '?') ifTrue: [
			"Remove this issue from all other issues' dependencies"
			IssueRepository uniqueInstance allIssues do: [ :otherIssue |
				otherIssue dependencies remove: issue ifAbsent: [] ].
			
			IssueRepository uniqueInstance removeIssue: issue.
			detailsForm clearForm.
			currentIssue := nil.
			self updateGanttChart ] ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> fieldChanged [
	"Update the currently selected issue when fields change"
	currentIssue ifNotNil: [ :issue |
		issue title: detailsForm titleText.
		issue description: detailsForm descriptionText.
		issue status: detailsForm selectedStatus.
		issue priority: detailsForm selectedPriority.
		issue startDate: detailsForm selectedStartDate.
		issue duration: detailsForm selectedDuration.
		issue dueDate: detailsForm selectedDueDate.
		self updateGanttChart.
		"Refresh dependencies display if they changed"
		detailsForm ensureDependenciesInitialized.    "Added this line"
		detailsForm loadDependencies: issue ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> filterChanged [
	self updateGanttChart
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> getFilteredIssues [
	| filteredIssues |
	filteredIssues := IssueRepository uniqueInstance allIssues.
	
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
			startDate := issue dependencyAwareStartDate.
			endDate := issue dependencyAwareEndDate.
			startDate notNil and: [ endDate notNil and: [
				"Issue is active today if today falls between start and end dates"
				today between: startDate asDate and: endDate asDate ] ] ] ].
	
	toolbar dueDateFilter = #week ifTrue: [
		| today weekFromNow |
		today := Date today.
		weekFromNow := today addDays: 7.
		filteredIssues := filteredIssues select: [ :issue |
			| startDate endDate |
			startDate := issue dependencyAwareStartDate.
			endDate := issue dependencyAwareEndDate.
			startDate notNil and: [ endDate notNil and: [
				"Issue is active this week if it overlaps with the week period"
				(startDate asDate <= weekFromNow) and: [ endDate asDate >= today ] ] ] ] ].
	
	^ filteredIssues
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> hasCurrentIssue [
	^ currentIssue notNil
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> initializePresenters [

	issues := IssueRepository uniqueInstance allIssues.
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
	issues := IssueRepository uniqueInstance allIssues.
	self updateGanttChart

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
    | repository allIssues currentIndex itemToMove |
    currentIssue ifNil: [ ^ self ].
    
    itemToMove := currentIssue.
    repository := IssueRepository uniqueInstance.
    allIssues := repository allIssues.
    currentIndex := allIssues indexOf: itemToMove.
    
    currentIndex < allIssues size ifTrue: [
        "Swap directly in the repository's internal collection"
        repository swapIssueAt: currentIndex with: currentIndex + 1.
        
        "Rebuild the Gantt chart"
        currentIssue := itemToMove.  "Maintain selection"
        self updateGanttChart.
        self updateMoveButtonsState ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> moveIssueUp [
    | repository allIssues currentIndex itemToMove |
    currentIssue ifNil: [ ^ self ].
    
    itemToMove := currentIssue.
    repository := IssueRepository uniqueInstance.
    allIssues := repository allIssues.
    currentIndex := allIssues indexOf: itemToMove.
    
    currentIndex > 1 ifTrue: [
        "Swap directly in the repository's internal collection"
        repository swapIssueAt: currentIndex with: currentIndex - 1.
        
        "Rebuild the Gantt chart"
        currentIssue := itemToMove.  "Maintain selection"
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
    tablePresenter := IssueTrackerPresenter new.
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
