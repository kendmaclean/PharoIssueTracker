Class {
	#name : 'IssueDependencyDialog',
	#superclass : 'SpPresenter',
	#instVars : [
		'dependenciesList',
		'addButton',
		'removeButton',
		'issue',
		'onDependencyChangedBlock'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'controlling' }
IssueDependencyDialog class >> openFor: anIssue [
	"Open a dialog to manage dependencies for the given issue"
	| dialog |
	dialog := self new.
	dialog issue: anIssue.
	^ dialog open
]

{ #category : 'initialization' }
IssueDependencyDialog >> addDependency [
	"Add dependency and trigger callback"
	| validCandidates selectedIssue |
	issue ifNil: [ ^ self ].
	
	"Use the Handler to find valid candidates from the repository"
	validCandidates := issue dependencyHandler  
		availableDependenciesIn: IssueRepository uniqueInstance allIssues.
	
	validCandidates ifEmpty: [  
		^ self inform: 'No available issues to add as dependencies' ].
	
	selectedIssue := UIManager default  
		chooseFrom: (validCandidates collect: #title)
		values: validCandidates
		title: 'Select issue this depends on:'.
	
	selectedIssue ifNotNil: [ 
		[  
			issue addDependency: selectedIssue.
			self refreshDependencies.
			
			"NEW: Auto-save changes"
			IssueRepository uniqueInstance autoSave.
			
			"Execute callback if provided"
			onDependencyChangedBlock ifNotNil: [ onDependencyChangedBlock value ]
		] on: Error do: [ :ex | self inform: ex messageText ] ]
]

{ #category : 'initialization' }
IssueDependencyDialog >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 8;
		add: dependenciesList;
		add: (SpBoxLayout newLeftToRight
			spacing: 5;
			add: addButton;
			add: removeButton;
			yourself) expand: false;
		yourself
]

{ #category : 'initialization' }
IssueDependencyDialog >> initializePresenters [
	"Dependencies table"
	dependenciesList := self newTable.
	dependenciesList  
		addColumn: ((SpStringTableColumn  
			title: 'Dependencies (this issue depends on)'  
			evaluated: [ :anIssue | anIssue title ]) yourself);
		beResizable.
	
	"Add context menu for deletion"
	dependenciesList contextMenu: [  
		self newMenu  
			addItem: [ :item |
				item  
					name: 'Remove dependency';
					icon: (self iconNamed: #delete);
					action: [ self removeDependency ] ];
			yourself ].
	
	"Add dependency button"
	addButton := self newButton
		label: 'Add Dependency';
		icon: (self iconNamed: #link);
		action: [ self addDependency ];
		yourself.
	
	"Remove dependency button"
	removeButton := self newButton
		label: 'Remove Selected';
		icon: (self iconNamed: #delete);
		action: [ self removeDependency ];
		yourself.
	
	"NEW: Initialize the callback block to nil"
	onDependencyChangedBlock := nil
]

{ #category : 'initialization' }
IssueDependencyDialog >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: 'Manage Dependencies';
		initialExtent: 500 @ 400;
		centered
]

{ #category : 'initialization' }
IssueDependencyDialog >> issue: anIssue [
	issue := anIssue.
	self refreshDependencies
]

{ #category : 'initialization' }
IssueDependencyDialog >> onDependencyChanged: aBlock [
	"Set a callback to be executed when dependencies change"
	onDependencyChangedBlock := aBlock
]

{ #category : 'initialization' }
IssueDependencyDialog >> refreshDependencies [
	issue ifNotNil: [
		dependenciesList items: issue dependencies ]
]

{ #category : 'initialization' }
IssueDependencyDialog >> removeDependency [
	"Remove dependency and trigger callback"

	| selectedDep |
	issue ifNil: [ ^ self ].

	"Try to get the selected item from table"
	selectedDep := dependenciesList selection selectedItem.

	selectedDep ifNil: [
		^ self inform: 'Please select a dependency to remove' ].

	issue removeDependency: selectedDep.
	self refreshDependencies.

	"Auto-save changes"
	IssueRepository uniqueInstance autoSave.

	"Execute callback if provided"
	onDependencyChangedBlock ifNotNil: [ onDependencyChangedBlock value ]
]
