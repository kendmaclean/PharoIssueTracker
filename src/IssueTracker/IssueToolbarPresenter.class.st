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
		'hideClosedIssues'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
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
		  addLast: chartButton;
		  addLast: saveButton;
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
		
	"Action button"
	chartButton := self newButton
		label: 'Chart';
		icon: (self iconNamed: #chart);
		action: [ self onShowChart ];
		yourself.
		
	saveButton := self newButton
		label: 'Save';
		icon: (self iconNamed: #smallSave);
		help: 'Save Pharo image';
		action: [ self onSaveImage ];
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
	self owner filterChanged
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowChart [
	self owner showChart
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowToday [
	dueDateFilter := #today.
	self updateButtonStates.
	self owner filterChanged
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onShowWeek [
	dueDateFilter := #week.
	self updateButtonStates.
	self owner filterChanged
]

{ #category : 'initialization' }
IssueToolbarPresenter >> onToggleHideClosed [
	hideClosedIssues := hideClosedIssues not.
	hideClosedButton label: (hideClosedIssues
		ifTrue: [ 'Show Closed' ]
		ifFalse: [ 'Hide Closed' ]).
	self owner filterChanged
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
