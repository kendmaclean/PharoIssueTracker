Class {
	#name : 'GanttChartBuilder',
	#superclass : 'Object',
	#traits : 'TIssueTrackerTrait',
	#classTraits : 'TIssueTrackerTrait classTrait',
	#instVars : [
		'canvas',
		'issues',
		'leftMargin',
		'clickCallback',
		'rightClickCallback'
	],
	#category : 'IssueTracker-UI',
	#package : 'IssueTracker',
	#tag : 'UI'
}

{ #category : 'initialization' }
GanttChartBuilder >> addDateAxisFrom: baselineDate to: maxDate issueCount: issueCount [
	"Add date axis at the top of the chart"

	| daySpan interval currentDate xPosition finalLabel finalDays |
	daySpan := maxDate julianDayNumber - baselineDate julianDayNumber
		           max: 1.

	"Determine appropriate interval (weekly for now)"
	interval := 7.

	currentDate := baselineDate.
	[ currentDate <= maxDate ] whileTrue: [
		| label days |
		days := currentDate julianDayNumber - baselineDate julianDayNumber.
		xPosition := leftMargin + (days * 20).

		label := RSLabel new
			         text: currentDate asDate yyyymmdd;
			         fontSize: 8;
			         yourself.

		label translateBy: xPosition @ -20.
		canvas add: label.

		"Add vertical grid line"
		self addGridLineAt: xPosition height: issueCount * 35.

		currentDate := currentDate asDate addDays: interval ].

	"Add final date"
	finalDays := maxDate julianDayNumber - baselineDate julianDayNumber.
	xPosition := leftMargin + (finalDays * 20).
	finalLabel := RSLabel new
		              text: maxDate asDate yyyymmdd;
		              fontSize: 8;
		              yourself.
	finalLabel translateBy: xPosition @ -20.
	canvas add: finalLabel.
	self addGridLineAt: xPosition height: issueCount * 35
]

{ #category : 'initialization' }
GanttChartBuilder >> addDependencyArrowsFor: filteredIssues shapeMap: issueShapeMap [
	"Add dependency arrows between issues"
	
	filteredIssues do: [ :issue |
		issue dependencies do: [ :dependency |
			| fromShape toShape |
			fromShape := issueShapeMap at: dependency ifAbsent: [ nil ].
			toShape := issueShapeMap at: issue ifAbsent: [ nil ].
			
			(fromShape notNil and: [ toShape notNil ]) ifTrue: [
				self createArrowFrom: fromShape to: toShape ] ] ]
]

{ #category : 'initialization' }
GanttChartBuilder >> addGridLineAt: xPosition height: height [
	"Add a vertical grid line at the specified x position"
	| line |
	
	line := RSLine new
		from: xPosition @ 0;
		to: xPosition @ height;
		color: (Color gray alpha: 0.2);
		width: 1;
		yourself.
	
	canvas add: line.
	line pushBack
]

{ #category : 'initialization' }
GanttChartBuilder >> addInteractionsTo: shape for: issue isMilestone: isMilestone hasDelayDue: hasDelayDue originalStart: originalStart [
	"Add all interactions (click, right-click, tooltip) to a shape"
	
	"Add click handler - must be set by the presenter"
	shape
		when: RSMouseClick
		do: [ :evt | self onIssueClicked: issue with: evt ]
		for: self.
	
	"Add right-click context menu - must be set by the presenter"
	shape
		when: RSMouseRightClick
		do: [ :evt | self onIssueRightClicked: issue with: evt ]
		for: self.
	
	"Add tooltip"
	shape @ (RSPopup text: [ :i |
		self createTooltipFor: i isMilestone: isMilestone hasDelayDue: hasDelayDue originalStart: originalStart ])
]

{ #category : 'initialization' }
GanttChartBuilder >> build [
	"Main entry point to build the Gantt chart"
	| filteredIssues |
	
	"Filter issues that have dates"
	filteredIssues := issues select: [ :issue |
		issue dependencyAwareEndDate notNil and: [
			issue dependencyAwareStartDate notNil ] ].
	
	filteredIssues ifEmpty: [ ^ self showEmptyMessage ].
	
	^ self buildChartFor: filteredIssues
]

{ #category : 'initialization' }
GanttChartBuilder >> buildChartFor: filteredIssues [
	"Build the complete Gantt chart for the given issues"
	| shapes issueShapeMap baselineDate maxDate |
	
	baselineDate := (filteredIssues collect: #dependencyAwareStartDate) min.
	maxDate := (filteredIssues collect: #dependencyAwareEndDate) max.
	
	shapes := OrderedCollection new.
	issueShapeMap := Dictionary new.
	
	"Create bars/diamonds for each issue"
	self 
		createShapes: shapes 
		shapeMap: issueShapeMap 
		for: filteredIssues 
		baseline: baselineDate.
	
	canvas addAll: shapes.
	
	"Draw dependency arrows"
	self 
		addDependencyArrowsFor: filteredIssues 
		shapeMap: issueShapeMap.
	
	"Add date axis"
	self 
		addDateAxisFrom: baselineDate 
		to: maxDate 
		issueCount: filteredIssues size.
	
	canvas @ RSCanvasController.
	^ canvas
]

{ #category : 'initialization' }
GanttChartBuilder >> canvas: aCanvas [
	canvas := aCanvas
]

{ #category : 'initialization' }
GanttChartBuilder >> createArrowFrom: fromShape to: toShape [
	"Create an arrow line from one shape to another"
	| line |
	
	line := RSArrowedLine new
		from: fromShape;
		to: toShape;
		color: (Color blue alpha: 0.5);
		width: 2;
		attachPoint: RSBorderAttachPoint new;
		yourself.
	
	canvas add: line.
	line pushBack
]

{ #category : 'initialization' }
GanttChartBuilder >> createBarShape: issue width: width hasDelayDue: hasDelayDue [
	"Create a bar shape for a regular issue"
	| shape |
	
	shape := RSBox new
		width: width;
		height: 25;
		color: (hasDelayDue
			ifTrue: [ (self colorForStatus: issue status) darker ]
			ifFalse: [ self colorForStatus: issue status ]);
		model: issue;
		yourself.
	
	hasDelayDue ifTrue: [
		shape border: (RSBorder new
			color: Color red;
			width: 2) ].
	
	shape translateBy: width / 2 @ 0.
	
	^ shape
]

{ #category : 'initialization' }
GanttChartBuilder >> createCompositeFor: issue at: index baseline: baselineDate [
	"Create a composite shape (bar/diamond + label) for a single issue"
	| shape label composite startDays endDays startX width hasDelayDue originalStart isMilestone |
	
	startDays := issue dependencyAwareStartDate julianDayNumber 
		- baselineDate julianDayNumber.
	endDays := issue dependencyAwareEndDate julianDayNumber 
		- baselineDate julianDayNumber.
	
	originalStart := issue computedStartDate.
	hasDelayDue := originalStart notNil and: [
		issue dependencyAwareStartDate > originalStart ].
	
	startX := leftMargin + (startDays * 20).
	width := (endDays - startDays max: 1) * 20.
	
	"Check if this is a milestone"
	isMilestone := issue status = #milestone.
	
	"Create shape based on type"
	shape := isMilestone
		ifTrue: [ self createMilestoneShape: issue hasDelayDue: hasDelayDue ]
		ifFalse: [ self createBarShape: issue width: width hasDelayDue: hasDelayDue ].
	
	"Create label"
	label := self createLabelFor: issue isMilestone: isMilestone hasDelayDue: hasDelayDue width: width.
	
	"Create composite"
	composite := RSComposite new
		shapes: { shape. label };
		model: issue;
		yourself.
	
	composite translateBy: startX @ ((index - 1) * 35).
	
	"Add interactions"
	self addInteractionsTo: shape for: issue isMilestone: isMilestone hasDelayDue: hasDelayDue originalStart: originalStart.
	
	^ composite
]

{ #category : 'initialization' }
GanttChartBuilder >> createLabelFor: issue isMilestone: isMilestone hasDelayDue: hasDelayDue width: width [
	"Create a label for an issue"
	| label |
	
	label := RSLabel new
		text: (isMilestone
			ifTrue: [ '◆ ' , issue title , 
				(hasDelayDue ifTrue: [ ' (delayed)' ] ifFalse: [ '' ]) ]
			ifFalse: [ 
				hasDelayDue
					ifTrue: [ issue title , ' (delayed)' ]
					ifFalse: [ issue title ] ]);
		fontSize: 10;
		yourself.
	
	label translateBy: (isMilestone 
		ifTrue: [ 20 @ 0 ]
		ifFalse: [ width + 10 @ 0 ]).
	
	^ label
]

{ #category : 'initialization' }
GanttChartBuilder >> createMilestoneShape: issue hasDelayDue: hasDelayDue [
	"Create a diamond shape for a milestone"
	
	^ RSPolygon new
		points: { 0@(-15). 15@0. 0@15. -15@0 };
		color: Color yellow;
		border: (RSBorder new 
			color: (hasDelayDue ifTrue: [ Color red ] ifFalse: [ Color black ]);
			width: 2);
		model: issue;
		yourself
]

{ #category : 'initialization' }
GanttChartBuilder >> createShapes: shapes shapeMap: issueShapeMap for: filteredIssues baseline: baselineDate [
	"Create all issue shapes (bars and diamonds)"
	
	filteredIssues withIndexDo: [ :issue :index |
		| composite shape |
		composite := self createCompositeFor: issue at: index baseline: baselineDate.
		shape := composite shapes first.
		
		shapes add: composite.
		issueShapeMap at: issue put: shape ]
]

{ #category : 'initialization' }
GanttChartBuilder >> createTooltipFor: issue isMilestone: isMilestone hasDelayDue: hasDelayDue originalStart: originalStart [
	"Create tooltip text for an issue"
	| tooltip |
	
	tooltip := issue title , String cr 
		, 'Status: ' , issue status asString , String cr
		, 'Priority: ' , issue priority asString , String cr.
	
	isMilestone ifTrue: [
		tooltip := tooltip , 'Type: Milestone' , String cr ].
	
	originalStart ifNotNil: [
		tooltip := tooltip , 'Original Start: ' , originalStart asString , String cr ].
	
	tooltip := tooltip 
		, 'Actual Start: ' , issue dependencyAwareStartDate asString , String cr
		, 'End: ' , issue dependencyAwareEndDate asString , String cr
		, 'Duration: ' , issue computedDuration asString , ' days'.
	
	issue hasDependencies ifTrue: [
		tooltip := tooltip , String cr 
			, 'Dependencies: ' , issue dependencies size asString ].
	
	hasDelayDue ifTrue: [
		tooltip := tooltip , String cr , '⚠ Delayed by dependencies' ].
	
	^ tooltip
]

{ #category : 'initialization' }
GanttChartBuilder >> initialize [
	super initialize.
	leftMargin := 150
]

{ #category : 'initialization' }
GanttChartBuilder >> issues: aCollection [
	issues := aCollection
]

{ #category : 'initialization' }
GanttChartBuilder >> leftMargin: anInteger [
	leftMargin := anInteger
]

{ #category : 'initialization' }
GanttChartBuilder >> onIssueClick: aBlock [
	"Set the callback for when an issue is clicked"
	clickCallback := aBlock
]

{ #category : 'initialization' }
GanttChartBuilder >> onIssueClicked: issue with: evt [
	"Handle issue click - delegate to callback if set"
	clickCallback ifNotNil: [ clickCallback cull: issue cull: evt ]
]

{ #category : 'initialization' }
GanttChartBuilder >> onIssueRightClick: aBlock [
	"Set the callback for when an issue is right-clicked"
	rightClickCallback := aBlock
]

{ #category : 'initialization' }
GanttChartBuilder >> onIssueRightClicked: issue with: evt [
	"Handle issue right-click - delegate to callback if set"
	rightClickCallback ifNotNil: [ rightClickCallback cull: issue cull: evt ]
]

{ #category : 'initialization' }
GanttChartBuilder >> showEmptyMessage [
	"Show a message when there are no issues to display"
	| label |
	
	label := RSLabel new
		text: 'No issues with dates to display';
		fontSize: 14;
		color: Color gray;
		yourself.
	
	label translateBy: 200 @ 100.
	canvas add: label.
	
	^ canvas
]
