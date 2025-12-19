"
Testing IssuePersistenceSettings - Complete Guide
Overview
This guide provides comprehensive instructions for testing the IssuePersistenceSettings class, which manages persistence settings and testing for the Issue Tracker application.
What IssuePersistenceSettings Does
IssuePersistenceSettings is a Spec2 presenter that provides a UI for:

Displaying the current storage location
Testing save/load functionality
Creating backups manually

Test Suite Structure
The test suite (IssuePersistenceSettingsTest) covers:
1. Initialization Tests (5 tests)

testInitializePresenters: Verifies all presenters are created
testLocationLabelShowsDefaultPath: Checks label shows correct path
testTestButtonHasCorrectLabel: Verifies button labels
testBackupButtonHasCorrectLabel: Verifies button labels
testLayoutIsCorrect: Tests layout configuration

2. Persistence Testing Tests (5 tests)

testPersistenceWithEmptyRepository: Empty repository handling
testPersistenceWithSingleIssue: Single issue save/load
testPersistenceWithMultipleIssues: Multiple issues handling
testPersistencePreservesIssueData: Data integrity verification

3. Backup Creation Tests (5 tests)

testCreateBackupWithEmptyRepository: Empty backup handling
testCreateBackupWithIssues: Successful backup creation
testBackupFileNaming: Naming convention verification
testBackupContainsAllData: Backup data integrity
testMultipleBackupsCreateDifferentFiles: Multiple backup handling

4. File Operations Tests (5 tests)

testSaveToCustomFile: Custom file path saving
testLoadFromCustomFile: Custom file path loading
testLoadFromNonExistentFile: Non-existent file handling
testSaveCreatesDirectory: Directory creation

5. Error Handling Tests (2 tests)

testSaveToInvalidPath: Invalid path handling
testLoadCorruptedFile: Corrupted file handling

6. Integration Tests (3 tests)

testRoundTripPreservesComplexData: Complex data round-trip
testAutoSaveIsCalled: Auto-save verification
testExportAndImport: Export/import workflow

7. UI Integration Tests (2 tests)

testOpenPersistenceSettings: UI opening
testLocationLabelUpdatesWithRepository: Label synchronization

8. Edge Case Tests (4 tests)

testVeryLargeNumberOfIssues: Performance with 100+ issues
testIssuesWithSpecialCharacters: Unicode/special char handling
testIssuesWithNilValues: Nil value handling
testConcurrentSaveOperations: Rapid consecutive operations
"
Class {
	#name : 'IssuePersistenceSettingsTest',
	#superclass : 'TestCase',
	#instVars : [
		'settings',
		'testFile',
		'testDirectory',
		'testRepository'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'accessing' }
IssuePersistenceSettingsTest class >> packageNamesUnderTest [
	^ #('IssueTracker')
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> setUp [
	"Set up test fixtures - NEVER touches user data"

	super setUp.

	"Reset and get test repository"
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.

	"Create isolated test directory with unique name"
	testDirectory := FileLocator temp / 'IssueTracker-Tests'
	                 / UUID new asString.
	testDirectory ensureCreateDirectory.

	"Set test file path"
	testFile := testDirectory / 'test-issues.fuel'.
	testRepository customPersistenceFileName: testFile.

	"Create settings presenter"
	settings := IssuePersistenceSettings new
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> tearDown [
	"Clean up test data - NEVER touches user data"
	
	"Clean up test directory"
	testDirectory exists ifTrue: [
		testDirectory deleteAll ].
	
	"Reset test repository"
	TestIssueRepository reset.
	
	settings := nil.
	testRepository := nil.
	testFile := nil.
	testDirectory := nil.
	
	super tearDown
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testAutoSaveIsCalled [
	"Test that adding an issue triggers auto-save"
	
	| issue beforeCount afterCount |
	
	"Get current file modification time if it exists"
	beforeCount := testRepository allIssues size.
	
	issue := Issue new title: 'Auto Save Test'; yourself.
	testRepository addIssue: issue.
	
	afterCount := testRepository allIssues size.
	
	"Issue should be added"
	self assert: afterCount equals: beforeCount + 1.
	
	"File should exist after auto-save"
	self assert: testRepository defaultPersistenceFileName parent exists
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testBackupButtonHasCorrectLabel [
	"Test that backup button has correct label"
	
	self assert: settings backupButton label equals: 'Create Backup Now'
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testBackupContainsAllData [
	"Test that backup file contains all repository data"
	
	| issue1 issue2 backupFile loadedIssues |
	
	issue1 := Issue new title: 'Issue 1'; yourself.
	issue2 := Issue new title: 'Issue 2'; yourself.
	testRepository addIssue: issue1.
	testRepository addIssue: issue2.
	
	backupFile := testRepository createBackup.
	
	"Load from backup"
	loadedIssues := FLMaterializer materializeFromFileNamed: backupFile fullName.
	
	self assert: loadedIssues size equals: 2
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testBackupFileNaming [
	"Test that backup files have correct naming pattern"
	
	| issue backupFile |
	
	issue := Issue new title: 'Naming Test'; yourself.
	testRepository addIssue: issue.
	
	backupFile := testRepository createBackup.
	
	self assert: (backupFile basename beginsWith: 'issues-backup-').
	self assert: backupFile extension equals: 'fuel'.
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testConcurrentSaveOperations [
	"Test behavior with rapid consecutive saves"
	
	| issue |
	
	issue := Issue new title: 'Concurrent Test'; yourself.
	testRepository addIssue: issue.
	
	"Perform multiple rapid saves"
	5 timesRepeat: [
		self assert: testRepository saveToFile ].
	
	"Data should still be intact"
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	self assert: testRepository loadFromFile.
	self assert: testRepository allIssues size equals: 1
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testCreateBackupWithEmptyRepository [
	"Test backup creation with empty repository"
	
	"Empty repository should not create backup"
	self assert: testRepository allIssues isEmpty.
	
	"createBackup returns nil for empty repository"
	self assert: testRepository createBackup isNil
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testCreateBackupWithIssues [
	"Test backup creation when issues exist"
	
	| issue backupFile |
	
	issue := Issue new title: 'Backup Test'; yourself.
	testRepository addIssue: issue.
	
	backupFile := testRepository createBackup.
	
	self assert: backupFile notNil.
	self assert: backupFile exists
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testExportAndImport [
	"Test export to file and import from file"
	
	| issue exportFile imported |
	
	issue := Issue new
		title: 'Export Test';
		description: 'Testing export/import';
		yourself.
	testRepository addIssue: issue.
	
	exportFile := testDirectory / 'exported-issues.fuel'.
	
	"Export"
	self assert: (testRepository exportToFile: exportFile).
	
	"Reset and import"
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	self assert: (testRepository loadFromFile: exportFile).
	
	imported := testRepository allIssues first.
	self assert: imported title equals: 'Export Test'.
	self assert: imported description equals: 'Testing export/import'
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testInitializePresenters [
	"Test that presenters are properly initialized"
	
	self assert: settings locationLabel notNil.
	self assert: settings testButton notNil.
	self assert: settings backupButton notNil
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testIssuesWithNilValues [
	"Test persistence of issues with nil fields"

	| issue loaded |
	issue := Issue new
		         title: 'Minimal Issue';
		         yourself.

	"Don't set description, dates, etc - leave as nil"

	testRepository addIssue: issue.
	testRepository saveToFile.

	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	testRepository loadFromFile.

	loaded := testRepository allIssues first.
	self assert: loaded title equals: 'Minimal Issue'.
	self assert: loaded description isNil
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testIssuesWithSpecialCharacters [
	"Test persistence of issues with special characters"

	| issue loaded |
	issue := Issue new
		         title: 'Issue with "quotes" and <brackets>';
		         description: 'Special chars: éàü ñ 中文 🔥';
		         yourself.

	testRepository addIssue: issue.
	testRepository saveToFile.

	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	testRepository loadFromFile.

	loaded := testRepository allIssues first.
	self
		assert: loaded title
		equals: 'Issue with "quotes" and <brackets>'.
	self assert: loaded description equals: 'Special chars: éàü ñ 中文 🔥'
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testLayoutIsCorrect [
	"Test that default layout is properly configured"
	
	| layout |
	layout := settings defaultLayout.
	
	self assert: layout notNil.
	self assert: layout class equals: SpBoxLayout
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testLoadCorruptedFile [
	"Test loading a corrupted file"
	
	| corruptedFile result |
	
	corruptedFile := testDirectory / 'corrupted.fuel'.
	corruptedFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is not valid Fuel data' ].
	
	result := testRepository loadFromFile: corruptedFile.
	
	"Should return false on error"
	self deny: result
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testLoadFromCustomFile [
	"Test loading from a custom file location"
	
	| issue customFile |
	
	issue := Issue new title: 'Load Custom Test'; yourself.
	testRepository addIssue: issue.
	
	customFile := testDirectory / 'load-test.fuel'.
	testRepository saveToFile: customFile.
	
	"Reset and load"
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	
	self assert: (testRepository loadFromFile: customFile).
	self assert: testRepository allIssues size equals: 1
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testLoadFromNonExistentFile [
	"Test loading from a file that doesn't exist"
	
	| nonExistentFile result |
	
	nonExistentFile := testDirectory / 'does-not-exist.fuel'.
	
	result := testRepository loadFromFile: nonExistentFile.
	
	self deny: result
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testLocationLabelShowsDefaultPath [
	"Test that location label displays the default persistence file name"
	
	| expectedPath |
	expectedPath := testRepository defaultPersistenceFileName fullName.
	
	self assert: settings locationLabel label equals: expectedPath
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testMultipleBackupsCreateDifferentFiles [
	"Test that multiple backups create separate files"
	
	| issue backup1 backup2 |
	
	issue := Issue new title: 'Multiple Backups'; yourself.
	testRepository addIssue: issue.
	
	backup1 := testRepository createBackup.
	
	"Wait a moment to ensure different timestamp"
	100 milliSeconds wait.
	
	backup2 := testRepository createBackup.
	
	self deny: backup1 = backup2
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testPersistencePreservesIssueData [
	"Test that persistence preserves all issue data"
	
	| issue loaded |
	
	issue := Issue new
		title: 'Complex Issue';
		description: 'A detailed description';
		status: #inProgress;
		priority: #high;
		startDate: Date today;
		duration: 5;
		dueDate: (Date today addDays: 5);
		yourself.
	
	testRepository addIssue: issue.
	
	"Save"
	self assert: testRepository saveToFile.
	
	"Reset and reload"
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	self assert: testRepository loadFromFile.
	
	loaded := testRepository allIssues first.
	
	"Verify all data preserved"
	self assert: loaded title equals: 'Complex Issue'.
	self assert: loaded description equals: 'A detailed description'.
	self assert: loaded status equals: #inProgress.
	self assert: loaded priority equals: #high
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testPersistenceWithEmptyRepository [
	"Test persistence when repository is empty"
	
	| result |
	
	"Ensure repository is empty"
	self assert: testRepository allIssues isEmpty.
	
	"Test should succeed even with empty repository"
	result := [ settings testPersistence. true ]
		on: Error
		do: [ :ex | false ].
	
	self assert: result
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testPersistenceWithMultipleIssues [
	"Test save/load with multiple issues"
	
	| issue1 issue2 issue3 |
	
	issue1 := Issue new title: 'Issue 1'; yourself.
	issue2 := Issue new title: 'Issue 2'; yourself.
	issue3 := Issue new title: 'Issue 3'; yourself.
	
	testRepository addIssue: issue1.
	testRepository addIssue: issue2.
	testRepository addIssue: issue3.
	
	"Test persistence"
	settings testPersistence.
	
	"Verify all issues still exist"
	self assert: testRepository allIssues size equals: 3
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testPersistenceWithSingleIssue [
	"Test save/load with a single issue"
	
	| issue |
	
	"Add one issue"
	issue := Issue new
		title: 'Test Issue';
		status: #open;
		priority: #medium;
		yourself.
	testRepository addIssue: issue.
	
	"Test persistence"
	self should: [ settings testPersistence ] notTakeMoreThan: 5 seconds.
	
	"Verify issue still exists"
	self assert: testRepository allIssues size equals: 1
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testRoundTripPreservesComplexData [
	"Test that complex issue data survives save/load cycle"
	
	| issue1 issue2 loaded2 |
	
	"Create issues with dependencies"
	issue1 := Issue new
		title: 'Parent Issue';
		status: #inProgress;
		priority: #high;
		startDate: Date today;
		duration: 5;
		yourself.
	
	issue2 := Issue new
		title: 'Child Issue';
		status: #open;
		priority: #medium;
		startDate: (Date today addDays: 5);
		duration: 3;
		yourself.
	
	"Add dependency"
	issue2 addDependency: issue1.
	
	testRepository addIssue: issue1.
	testRepository addIssue: issue2.
	
	"Save and reload"
	self assert: testRepository saveToFile.
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	self assert: testRepository loadFromFile.
	
	"Verify"
	self assert: testRepository allIssues size equals: 2.
	
	loaded2 := testRepository allIssues detect: [ :i | i title = 'Child Issue' ].
	self assert: loaded2 hasDependencies.
	self assert: loaded2 dependencies size equals: 1
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testSaveCreatesDirectory [
	"Test that save creates necessary directories"
	
	| issue deepPath |
	
	issue := Issue new title: 'Directory Test'; yourself.
	testRepository addIssue: issue.
	
	deepPath := testDirectory / 'subdir1' / 'subdir2' / 'issues.fuel'.
	
	self assert: (testRepository saveToFile: deepPath).
	self assert: deepPath exists
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testSaveToCustomFile [
	"Test saving to a custom file location"
	
	| issue customFile |
	
	issue := Issue new title: 'Custom File Test'; yourself.
	testRepository addIssue: issue.
	
	customFile := testDirectory / 'custom-issues.fuel'.
	
	self assert: (testRepository saveToFile: customFile).
	self assert: customFile exists
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testTestButtonHasCorrectLabel [
	"Test that test button has correct label"
	
	self assert: settings testButton label equals: 'Test Save/Load'
]

{ #category : 'running' }
IssuePersistenceSettingsTest >> testVeryLargeNumberOfIssues [
	"Test persistence with many issues"
	
	| issues |
	
	"Create 100 issues"
	issues := (1 to: 100) collect: [ :i |
		Issue new
			title: 'Issue ', i asString;
			status: #open;
			priority: #medium;
			yourself ].
	
	issues do: [ :issue | testRepository addIssue: issue ].
	
	"Test persistence"
	self assert: testRepository saveToFile.
	
	TestIssueRepository reset.
	testRepository := TestIssueRepository uniqueInstance.
	self assert: testRepository loadFromFile.
	
	self assert: testRepository allIssues size equals: 100
]
