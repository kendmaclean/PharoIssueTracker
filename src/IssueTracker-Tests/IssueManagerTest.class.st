"
Tests for IssueManager using TestIssueRepository subclass.

This approach:
- Uses a test-specific subclass (TestIssueRepository) with its own singleton
- Leaves the original IssueRepository completely untouched
- Stores test data in temp directory
- No modifications to production code required!
"
Class {
	#name : 'IssueManagerTest',
	#superclass : 'TestCase',
	#instVars : [
		'manager',
		'repository',
		'sampleIssues'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IssueManagerTest >> createSampleIssues [
	"Create sample issues for testing"
	| issue1 issue2 issue3 |
	
	issue1 := Issue new
		title: 'Test Issue 1';
		description: 'First test issue';
		status: #open;
		priority: #high;
		startDate: Date today;
		dueDate: (Date today addDays: 5);
		yourself.
	
	issue2 := Issue new
		title: 'Test Issue 2';
		description: 'Second test issue';
		status: #inProgress;
		priority: #medium;
		startDate: Date today;
		dueDate: (Date today addDays: 3);
		yourself.
	
	issue3 := Issue new
		title: 'Test Issue 3';
		description: 'Third test issue';
		status: #closed;
		priority: #low;
		yourself.
	
	sampleIssues := OrderedCollection with: issue1 with: issue2 with: issue3
]

{ #category : 'running' }
IssueManagerTest >> setUp [
	"Set up test fixtures with test repository"
	super setUp.
	
	"Reset the TEST repository to ensure clean state"
	TestIssueRepository reset.
	repository := TestIssueRepository uniqueInstance.
	
	"Initialize manager"
	manager := IssueManager new.
	
	self createSampleIssues
]

{ #category : 'running' }
IssueManagerTest >> tearDown [
	"Clean up after tests"
	manager := nil.
	sampleIssues := nil.
	
	"Reset test repository to clean state"
	TestIssueRepository reset.
	
	"Clean up test files"
	TestIssueRepository testPersistenceFile parent ensureDeleteAll.
	
	super tearDown
]

{ #category : 'running' }
IssueManagerTest >> testAddIssue [
	"Test adding an issue through the manager"
	| issue initialCount |
	
	initialCount := repository allIssues size.
	
	issue := Issue new
		title: 'New Issue';
		status: #open;
		yourself.
	
	repository addIssue: issue.
	
	self assert: repository allIssues size equals: initialCount + 1.
	self assert: (repository allIssues includes: issue)
]

{ #category : 'running' }
IssueManagerTest >> testAddNilIssue [
	"Test that adding nil raises an error"
	
	self should: [ repository addIssue: nil ] raise: Error
]

{ #category : 'running' }
IssueManagerTest >> testAutoSave [
	"Test that auto-save is called after modifications"

	| issue tempFile |
	tempFile := TestIssueRepository testPersistenceFile.
	tempFile ensureDelete.
	repository customPersistenceFileName: tempFile.
	issue := sampleIssues first.
	repository addIssue: issue.

	"File should exist after auto-save"
	self assert: tempFile exists.

	"Clean up"
	tempFile ensureDelete
]

{ #category : 'running' }
IssueManagerTest >> testCreateBackup [
	"Test creating a backup"
	| issue backupFile |
	
	issue := sampleIssues first.
	repository addIssue: issue.
	
	backupFile := repository createBackup.
	
	self assert: backupFile notNil.
	self assert: backupFile exists.
	self assert: (backupFile basename includesSubstring: 'backup').
	
	"Clean up"
	backupFile ensureDelete
]

{ #category : 'running' }
IssueManagerTest >> testCreateBackupEmptyRepository [
	"Test creating a backup with no issues"
	| backupFile |
	
	"Ensure repository is empty"
	repository allIssues copy do: [ :issue | repository removeIssue: issue ].
	
	backupFile := repository createBackup.
	
	"Should return nil for empty repository"
	self assert: backupFile isNil
]

{ #category : 'running' }
IssueManagerTest >> testCustomPersistenceLocation [
	"Test setting a custom persistence file location"

	| customFile |
	customFile := FileLocator temp / 'IssueTracker-Tests' / 'custom-location.fuel'.

	repository customPersistenceFileName: customFile.

	self assert: repository defaultPersistenceFileName equals: customFile
]

{ #category : 'running' }
IssueManagerTest >> testExportAndImport [
	"Test exporting and importing issues"
	| tempFile loadedRepository originalCount |
	
	tempFile := FileLocator temp / 'test-export.fuel'.
	tempFile ensureDelete.
	
	sampleIssues do: [ :issue | repository addIssue: issue ].
	originalCount := repository allIssues size.
	
	"Export"
	repository exportToFile: tempFile.
	self assert: tempFile exists.
	
	"Reset and import"
	IssueRepository reset.
	loadedRepository := IssueRepository uniqueInstance.
	loadedRepository loadFromFile: tempFile.
	
	"Verify"
	self assert: loadedRepository allIssues size equals: originalCount.
	
	"Clean up"
	tempFile ensureDelete
]

{ #category : 'running' }
IssueManagerTest >> testGetAllIssues [
	"Test retrieving all issues"
	
	sampleIssues do: [ :issue | repository addIssue: issue ].
	
	self assert: repository allIssues size >= sampleIssues size
]

{ #category : 'running' }
IssueManagerTest >> testRemoveIssue [
	"Test removing an issue through the manager"
	| issue initialCount |
	
	issue := sampleIssues first.
	repository addIssue: issue.
	initialCount := repository allIssues size.
	
	repository removeIssue: issue.
	
	self assert: repository allIssues size equals: initialCount - 1.
	self deny: (repository allIssues includes: issue)
]

{ #category : 'running' }
IssueManagerTest >> testSaveAndLoad [
	"Test saving and loading issues"
	| tempFile loadedRepository |
	
	tempFile := FileLocator temp / 'test-issues-save-load.fuel'.
	tempFile ensureDelete.
	
	sampleIssues do: [ :issue | repository addIssue: issue ].
	
	"Save to temp file"
	repository saveToFile: tempFile.
	self assert: tempFile exists.
	
	"Create new repository and load"
	IssueRepository reset.
	loadedRepository := IssueRepository uniqueInstance.
	loadedRepository loadFromFile: tempFile.
	
	"Verify loaded issues"
	self assert: loadedRepository allIssues size equals: sampleIssues size.
	
	"Clean up"
	tempFile ensureDelete
]

{ #category : 'running' }
IssueManagerTest >> testSwapIssues [
	"Test swapping two issues in the collection"
	| firstIssue secondIssue issues |
	
	sampleIssues do: [ :issue | repository addIssue: issue ].
	issues := repository allIssues.
	
	self assert: issues size >= 2.
	
	firstIssue := issues at: 1.
	secondIssue := issues at: 2.
	
	repository swapIssueAt: 1 with: 2.
	
	issues := repository allIssues.
	self assert: (issues at: 1) equals: secondIssue.
	self assert: (issues at: 2) equals: firstIssue
]

{ #category : 'running' }
IssueManagerTest >> testSwapIssuesInvalidIndices [
	"Test swapping with invalid indices"
	
	sampleIssues do: [ :issue | repository addIssue: issue ].
	
	"Should raise an error for invalid indices"
	self should: [ repository swapIssueAt: 1 with: 999 ] raise: Error
]
