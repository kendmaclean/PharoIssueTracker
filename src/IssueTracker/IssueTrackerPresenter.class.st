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
		'currentIssue'
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
IssueTrackerPresenter >> currentIssue [
    ^ currentIssue
]

{ #category : 'initialization' }
IssueTrackerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 0;
		  add: toolbar expand: false;
		  add: (SpPanedLayout newTopToBottom
				   positionOfSlider: 0.4;
				   add: issueList;
				   add: detailsForm;
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
	issueList := self instantiate: IssueListPresenter.
	detailsForm := self instantiate: IssueDetailsPresenter.
	
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Issue Tracker';
		initialExtent: 800 @ 600
]

{ #category : 'initialization' }
IssueTrackerPresenter >> issueListChanged [
	issues := IssueRepository uniqueInstance allIssues.
	self updateIssueList
]

{ #category : 'initialization' }
IssueTrackerPresenter >> onIssueSelected: anIssue [
	currentIssue := anIssue.
	detailsForm loadIssue: anIssue
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
	
	issueList items: filteredIssues
]
