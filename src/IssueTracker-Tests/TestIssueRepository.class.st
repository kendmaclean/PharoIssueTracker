"
A test-only subclass of IssueRepository that maintains its own singleton instance.
This allows tests to work with an isolated repository without touching the real user repository.

The test singleton is completely separate from the production singleton.
"
Class {
	#name : 'TestIssueRepository',
	#superclass : 'IssueRepository',
	#classVars : [
		'TestInstance'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'instance creation' }
TestIssueRepository class >> reset [
	"Reset only the test singleton"

	"First, reset the IssueManager that depends on this repository"
	IssueManager reset.

	TestInstance := nil
]

{ #category : 'instance creation' }
TestIssueRepository class >> resetAll [
	"Complete reset: clears the singleton AND deletes the persistence file.
    Use this to completely clear all issues from memory and disk."

	| persistenceFile |
	"First do a regular reset"
	self reset.

	"Get persistence file location - don't call uniqueInstance as it might reload!"
	persistenceFile := CustomPersistenceFileName
		                   ifNil: [ self testPersistenceFile ]
		                   ifNotNil: [ CustomPersistenceFileName ].

	"Clear the custom persistence file name"
	CustomPersistenceFileName := nil.

	"Delete the persistence file if it exists"
	persistenceFile exists ifFalse: [ ^ self ].
	persistenceFile delete
]

{ #category : 'instance creation' }
TestIssueRepository class >> testPersistenceFile [
	"Use a dedicated test file location that won't interfere with user data"
	^ FileLocator temp / 'IssueTracker-Tests' / 'test-issues.fuel'
]

{ #category : 'instance creation' }
TestIssueRepository class >> uniqueInstance [
	"Return the test-specific singleton instance"
	^ TestInstance ifNil: [ TestInstance := self new ]
]

{ #category : 'persistence' }
TestIssueRepository >> defaultPersistenceFileName [
	"Override to use test-specific location"

	"^ self class testPersistenceFile"
	
	^ CustomPersistenceFileName ifNil: [
		  self class testPersistenceFile ]
]

{ #category : 'persistence' }
TestIssueRepository >> testPersistence [
	"Test that save/load works properly"

	| repo savedOk loadedOk |
	repo := TestIssueRepository uniqueInstance.

	"Test saving"
	savedOk := repo saveToFile.

	savedOk
		ifTrue: [ "Test loading"
			loadedOk := repo loadFromFile.
			loadedOk
				ifTrue: [ self inform: 'Persistence test successful!' ]
				ifFalse: [ self inform: 'Load test failed!' ] ]
		ifFalse: [ self inform: 'Save test failed!' ]
]
