Class {
	#name : 'IssueTrackerGanttPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'toolbar',
		'ganttCanvas',
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
IssueTrackerGanttPresenter class >> open [
	<script>
	^ self new open
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> addDateAxis: rsCanvas from: startDate to: endDate count: issueCount leftMargin: leftMargin [
	| currentDate xPos labels dateLabel gridLine |
	
	labels := OrderedCollection new.
	currentDate := startDate.
	
	"Add labels every week"
	[ currentDate <= endDate ] whileTrue: [
		xPos := leftMargin + ((currentDate julianDayNumber - startDate julianDayNumber) * 20).
		
		"Date label"
		dateLabel := RSLabel new
			text: currentDate asString;
			fontSize: 8;
			color: Color gray;
			yourself.
		dateLabel translateBy: xPos @ -20.
		labels add: dateLabel.
		
		"Vertical grid line"
		gridLine := RSLine new
			startPoint: xPos @ -10;
			endPoint: xPos @ (issueCount * 35 + 10);
			color: (Color gray alpha: 0.2);
			yourself.
		labels add: gridLine.
		
		currentDate := currentDate addDays: 7 ].
	
	rsCanvas addAll: labels
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> addDependencyArrows: rsCanvas forIssues: issueList shapeMap: issueShapeMap [
	"Draw arrows from dependencies to dependent issues"
	| arrows |
	arrows := OrderedCollection new.
	issueList do: [ :issue |
		| toShape |
		toShape := issueShapeMap at: issue ifAbsent: [ nil ].
		issue dependencies do: [ :dependency |
			| fromShape line |
			fromShape := issueShapeMap at: dependency ifAbsent: [ nil ].
			(fromShape notNil and: [ toShape notNil ]) ifTrue: [ 
				line := RSArrowedLine new
					from: fromShape;
					to: toShape;
					color: (Color blue alpha: 0.5);
					width: 2;
					attachPoint: RSBorderAttachPoint new;
					yourself.
				arrows add: line ] ] ].
	rsCanvas addAll: arrows
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> addDependencyArrows: rsCanvas issues: issues shapeMap: issueShapeMap [
	"Draw arrows from dependencies to dependent issues"
	| arrows |
	arrows := OrderedCollection new.
	issues do: [ :issue |
		| toShape |
		toShape := issueShapeMap at: issue ifAbsent: [ nil ].
		issue dependencies do: [ :dependency |
			| fromShape line |
			fromShape := issueShapeMap at: dependency ifAbsent: [ nil ].
			(fromShape notNil and: [ toShape notNil ]) ifTrue: [ 
				line := RSArrowedLine new
					from: fromShape;
					to: toShape;
					color: (Color blue alpha: 0.5);
					width: 2;
					attachPoint: RSBorderAttachPoint new;
					yourself.
				arrows add: line ] ] ].
	rsCanvas addAll: arrows
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> addDependencyTo: anIssue [
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
			self updateGanttChart.
			self inform: 'Dependency added successfully'
		] on: Error do: [ :ex | self inform: ex messageText ] ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> anageDependenciesFor: anIssue [
	IssueDependencyDialog openFor: anIssue.
	"Refresh after dialog closes"
	self updateGanttChart.
	"Update details form if this is the current issue"    "Added these 3 lines"
	currentIssue = anIssue ifTrue: [
		detailsForm ensureDependenciesInitialized.
		detailsForm loadDependencies: anIssue ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> buildGanttChart [
	ganttCanvas script: [ :rsCanvas | self buildGanttOn: rsCanvas ]
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> buildGanttOn: rsCanvas [

	| filteredIssues shapes baselineDate maxDate daySpan leftMargin issueShapeMap |
	"Apply filters"
	filteredIssues := self getFilteredIssues.

	"Filter issues that have dates"
	filteredIssues := filteredIssues select: [ :issue |
		                  issue dependencyAwareEndDate notNil and: [
			                  issue dependencyAwareStartDate notNil ] ].

	filteredIssues ifEmpty: [ ^ self showEmptyMessageOn: rsCanvas ].

	"Calculate date range"
	baselineDate := (filteredIssues collect: #dependencyAwareStartDate)
		                min.
	maxDate := (filteredIssues collect: #dependencyAwareEndDate) max.
	daySpan := maxDate julianDayNumber - baselineDate julianDayNumber
		           max: 1.
	leftMargin := 150.

	shapes := OrderedCollection new.
	issueShapeMap := Dictionary new.

	"Create bars for each issue"
	filteredIssues withIndexDo: [ :issue :index |
		| bar width label composite startDays endDays startX hasDelayDue originalStart |
		startDays := issue dependencyAwareStartDate julianDayNumber
		             - baselineDate julianDayNumber.
		endDays := issue dependencyAwareEndDate julianDayNumber
		           - baselineDate julianDayNumber.

		originalStart := issue computedStartDate.
		hasDelayDue := originalStart notNil and: [
			               issue dependencyAwareStartDate > originalStart ].

		startX := leftMargin + (startDays * 20).
		width := (endDays - startDays max: 1) * 20.

		"Create clickable bar"
		bar := RSBox new
			       width: width;
			       height: 25;
			       color: (hasDelayDue
					        ifTrue: [ (self colorForStatus: issue status) darker ]
					        ifFalse: [ self colorForStatus: issue status ]);
			       model: issue;
			       yourself.

		hasDelayDue ifTrue: [
			bar border: (RSBorder new
					 color: Color red;
					 width: 2) ].

		bar translateBy: width / 2 @ 0.

		"Create label"
		label := RSLabel new
			         text: (hasDelayDue
					          ifTrue: [ issue title , ' (delayed)' ]
					          ifFalse: [ issue title ]);
			         fontSize: 10;
			         yourself.

		label translateBy: width + 10 @ 0.

		"Create composite"
		composite := RSComposite new
			             shapes: {
					             bar.
					             label };
			             model: issue;
			             yourself.

		composite translateBy: startX @ (index * 35).

		shapes add: composite.
		issueShapeMap at: issue put: bar.

		"Add click handler to select issue"
		bar
			when: RSMouseClick
			do: [ :evt | self onIssueSelected: issue ]
			for: self.

		"Add right-click context menu"
		bar
			when: RSMouseRightClick
			do: [ :evt | self showContextMenuFor: issue at: evt ]
			for: self.

		"Add tooltip"
		bar @ (RSPopup text: [ :i |
			 | tooltip |
			 tooltip := i title , String cr , 'Status: ' , i status asString
			            , String cr , 'Priority: ' , i priority asString
			            , String cr.
			 originalStart ifNotNil: [
				 tooltip := tooltip , 'Original Start: ' , originalStart asString
				            , String cr ].
			 tooltip := tooltip , 'Actual Start: '
			            , i dependencyAwareStartDate asString , String cr
			            , 'End: ' , i dependencyAwareEndDate asString
			            , String cr , 'Duration: '
			            , i computedDuration asString , ' days'.
			 i hasDependencies ifTrue: [
				 tooltip := tooltip , String cr , 'Dependencies: '
				            , i dependencies size asString ].
			 hasDelayDue ifTrue: [
				 tooltip := tooltip , String cr , '⚠ Delayed by dependencies' ].
			 tooltip ]) ].

	rsCanvas addAll: shapes.

	"Draw dependency arrows"
	self
		addDependencyArrows: rsCanvas
		forIssues: filteredIssues
		shapeMap: issueShapeMap.

	"Add date axis"
	self
		addDateAxis: rsCanvas
		from: baselineDate
		to: maxDate
		count: filteredIssues size
		leftMargin: leftMargin.

	rsCanvas @ RSCanvasController.
	^ rsCanvas
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> colorForStatus: aStatus [
	aStatus = #open ifTrue: [ ^ Color cyan ].
	aStatus = #inProgress ifTrue: [ ^ Color orange ].
	aStatus = #resolved ifTrue: [ ^ Color green ].
	aStatus = #closed ifTrue: [ ^ Color gray ].
	^ Color black
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
IssueTrackerGanttPresenter >> dependenciesChanged [
	"Called when dependencies are modified"
	self updateGanttChart.
	currentIssue ifNotNil: [ :issue |
		detailsForm ensureDependenciesInitialized.
		detailsForm loadDependencies: issue ]
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
		filteredIssues := filteredIssues select: [ :issue |
			issue dueDate notNil and: [ 
				issue dueDate asDate = Date today ] ] ].
	
	toolbar dueDateFilter = #week ifTrue: [
		| today weekFromNow |
		today := Date today.
		weekFromNow := today addDays: 7.
		filteredIssues := filteredIssues select: [ :issue |
			issue dueDate notNil and: [
				issue dueDate asDate between: today and: weekFromNow ] ] ].
	
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
        label: '↑ Move Up';
        icon: (self iconNamed: #up);
        help: 'Move selected issue up in order';
        action: [ self moveIssueUp ];
        enabled: false;
        yourself.
    
    moveDownButton := self newButton
        label: '↓ Move Down';
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
		initialExtent: 1200 @ 800
]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> issueListChanged [
	issues := IssueRepository uniqueInstance allIssues.
	self updateGanttChart

]

{ #category : 'initialization' }
IssueTrackerGanttPresenter >> manageDependenciesFor: anIssue [
	IssueDependencyDialog openFor: anIssue.
	"Refresh after dialog closes"
	self updateGanttChart.
	"Update details form if this is the current issue"    "Added these 3 lines"
	currentIssue = anIssue ifTrue: [
		detailsForm ensureDependenciesInitialized.
		detailsForm loadDependencies: anIssue ]
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
    "Close current window and open table view"
    | tablePresenter |
    tablePresenter := IssueTrackerPresenter new.
    tablePresenter open.
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
