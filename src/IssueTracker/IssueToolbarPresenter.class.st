Class {
	#name : 'IssueToolbarPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'showAllButton',
		'showTodayButton',
		'showWeekButton',
		'hideClosedButton',
		'chartButton',
		'saveButton',
		'dueDateFilter',
		'hideClosedIssues',
		'ganttButton',
		'statusLabel'
	],
	#category : 'IssueTracker-UI',
	#package : 'IssueTracker',
	#tag : 'UI'
}

{ #category : 'initialization' }
IssueToolbarPresenter >> defaultLayout [
      ^ SpBoxLayout newLeftToRight
          spacing: 5;
          add: showAllButton;
          add: showTodayButton;
          add: showWeekButton;
          add: hideClosedButton;
          add: ' ';
          add: statusLabel width: 250;  "Fixed width"
          addLast: chartButton;
          addLast: ganttButton;
          yourself

]

{ #category : 'initialization' }
IssueToolbarPresenter >> dueDateFilter [
	^ dueDateFilter
]

{ #category : 'initialization' }
IssueToolbarPresenter >> hideClosedIssues [
	^ hideClosedIssues
]

{ #category : 'initialization' }
IssueToolbarPresenter >> initializePresenters [
	"Add persistence buttons to toolbar"

	dueDateFilter := #all.
	hideClosedIssues := false.

	"Filtering buttons"
	showAllButton := self newButton
		                 label: '• All';
		                 help: 'Show all issues';
		                 action: [ self onShowAll ];
		                 yourself.

	showTodayButton := self newButton
		                   label: 'Today';
		                   help: 'Show issues due today';
		                   action: [ self onShowToday ];
		                   yourself.

	showWeekButton := self newButton
		                  label: 'This Week';
		                  help: 'Show issues due this week';
		                  action: [ self onShowWeek ];
		                  yourself.

	hideClosedButton := self newButton
		                    label: 'Hide Closed';
		                    help: 'Toggle closed issues visibility';
		                    action: [ self onToggleHideClosed ];
		                    yourself.

	"Action buttons"
	chartButton := self newButton
		               label: 'Issue Status';
		               icon: (self iconNamed: #smallCogInitialState);
		               action: [ self onShowChart ];
		               yourself.

	"Persistence: More options menu (backup, import, export)"
	ganttButton := self newButton
		               label: 'More...';
		               icon: (self iconNamed: #smallDoIt);
		               help: 'Backup, Import, Export (auto-save enabled)';
		               action: [
			               self owner buildPersistenceMenu
				               openWithSpecAtPointer ];
		               yourself.

	statusLabel := self newLabel
		               label: '';
		               yourself
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onSaveImage [

	Smalltalk snapshot: true andQuit: false.
	self owner inform: 'Image saved successfully (includes the IssueRepository)'
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowAll [

	dueDateFilter := #all.
	self updateButtonStates.
	self updateStatusLabel.
	self owner filterChanged
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowChart [

	IssueChartPresenter open
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowToday [
      dueDateFilter := #today.
      self updateButtonStates.
      self updateStatusLabel.
      self owner filterChanged

]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowWeek [
      dueDateFilter := #week.
      self updateButtonStates.
      self updateStatusLabel.
      self owner filterChanged

]

{ #category : 'initialization' }
IssueToolbarPresenter >> onToggleHideClosed [
      hideClosedIssues := hideClosedIssues not.
      hideClosedButton label: (hideClosedIssues
          ifTrue: [ 'Show Closed' ]
          ifFalse: [ 'Hide Closed' ]).
      self updateStatusLabel.  "NEW"
      self owner filterChanged


]

{ #category : 'initialization' }
IssueToolbarPresenter >> refreshStatus [
      self updateStatusLabel

]

{ #category : 'initialization' }
IssueToolbarPresenter >> updateButtonStates [
	showAllButton label: (dueDateFilter = #all 
		ifTrue: [ '• All' ] 
		ifFalse: [ 'All' ]).
	showTodayButton label: (dueDateFilter = #today 
		ifTrue: [ '• Today' ] 
		ifFalse: [ 'Today' ]).
	showWeekButton label: (dueDateFilter = #week 
		ifTrue: [ '• This Week' ] 
		ifFalse: [ 'This Week' ])
]

{ #category : 'initialization' }
IssueToolbarPresenter >> updateStatusLabel [

	| filteredIssues total endDate text |
	"Guard against nil owner during initialization"
	self owner ifNil: [
		statusLabel label: ''.
		^ self ].

	filteredIssues := self owner getFilteredIssues.
	total := filteredIssues
		         inject: 0
		         into: [ :sum :issue | sum + issue computedDuration ].
	endDate := Date today addDays: total.
	text := 'Total Duration: ' , total asString , ' days | End: '
	        , endDate yyyymmdd.
	statusLabel label: text
]
