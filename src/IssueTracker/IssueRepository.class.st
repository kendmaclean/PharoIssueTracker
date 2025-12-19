Class {
	#name : 'IssueRepository',
	#superclass : 'Object',
	#instVars : [
		'issues'
	],
	#classVars : [
		'CustomPersistenceFileName',
		'UniqueInstance'
	],
	#category : 'IssueTracker-Issue',
	#package : 'IssueTracker',
	#tag : 'Issue'
}

{ #category : 'instance creation' }
IssueRepository class >> reset [
    UniqueInstance := nil
]

{ #category : 'instance creation' }
IssueRepository class >> uniqueInstance [
    ^ UniqueInstance ifNil: [ UniqueInstance := self new ]
]

{ #category : 'initialization' }
IssueRepository >> addIssue: anIssue [
	
	anIssue ifNil: [ ^ self error: 'Parameter cannot be nil' ].
	
	issues add: anIssue.
	self autoSave
]

{ #category : 'initialization' }
IssueRepository >> allIssues [
    ^ issues copy
]

{ #category : 'persistence' }
IssueRepository >> autoSave [
	"Automatically save issues - call this after modifications"
	^ self saveToFile
]

{ #category : 'persistence' }
IssueRepository >> createBackup [
	"Create a timestamped backup of the current issues"
	| timestamp backupFile |
	
	issues isEmpty ifTrue: [ 
		^ nil "No point backing up empty data"
	].
	
	timestamp := DateAndTime now asString copyReplaceAll: ':' with: '-'.
	backupFile := self defaultPersistenceFileName parent / 
		('issues-backup-', timestamp, '.fuel').
	
	(self saveToFile: backupFile) ifTrue: [ 
		^ backupFile
	] ifFalse: [
		^ nil
	]
]

{ #category : 'persistence' }
IssueRepository >> customPersistenceFileName: aFileReference [
	"Set a custom persistence file location"
	CustomPersistenceFileName := aFileReference
]

{ #category : 'persistence' }
IssueRepository >> defaultPersistenceFileName [
	"Return the default file location for persisting issues"
	^ CustomPersistenceFileName ifNil: [ 
		FileLocator imageDirectory / 'IssueTracker' / 'issues.fuel' ]
]

{ #category : 'persistence' }
IssueRepository >> ensurePersistenceDirectory [
	"Ensure the default persistence directory exists"
	^ self ensurePersistenceDirectoryFor: self defaultPersistenceFileName
]

{ #category : 'persistence' }
IssueRepository >> ensurePersistenceDirectoryFor: aFileReference [
	"Ensure the directory for the given file reference exists"
	| directory |
	directory := aFileReference parent.
	directory ensureCreateDirectory.
	^ directory
]

{ #category : 'persistence' }
IssueRepository >> exportToFile: aFileReference [
	"Export issues to a specific file"
	^ self saveToFile: aFileReference
]

{ #category : 'initialization' }
IssueRepository >> initialize [
	"Initialize and try to load existing issues"
	super initialize.
	
	"Try to load existing issues, if file doesn't exist, start fresh"
	self loadFromFile ifFalse: [
		issues := OrderedCollection new
	]
]

{ #category : 'initialization' }
IssueRepository >> issues [
    ^ issues
]

{ #category : 'persistence' }
IssueRepository >> loadFromFile [
	"Load issues from the default file using Fuel"
	^ self loadFromFile: self defaultPersistenceFileName
]

{ #category : 'persistence' }
IssueRepository >> loadFromFile: aFileReference [
	"Load issues from the specified file using Fuel
	Fuel automatically handles all deserialization!"

	aFileReference exists ifFalse: [ ^ false "No file to load" ].

	[ issues := FLMaterializer materializeFromFileNamed:
		          aFileReference fullName.
	  ^ true ]
	on: Error do: [ :ex |
			UIManager default inform: 'Error loading issues: ' , ex messageText.
			^ false ]
]

{ #category : 'initialization' }
IssueRepository >> removeIssue: anIssue [
	issues remove: anIssue.
	self autoSave
]

{ #category : 'persistence' }
IssueRepository >> saveToFile [
	"Save all issues to the default file using Fuel"
	^ self saveToFile: self defaultPersistenceFileName
]

{ #category : 'persistence' }
IssueRepository >> saveToFile: aFileReference [
	"Save all issues to the specified file using Fuel"
	
	self ensurePersistenceDirectoryFor: aFileReference.
	
	[ 
		FLSerializer serialize: issues toFileNamed: aFileReference fullName.
		^ true
	] on: Error do: [ :ex |
		UIManager default inform: 'Error saving issues: ' , ex messageText.
		^ false ]
]

{ #category : 'initialization' }
IssueRepository >> swapIssueAt: index1 with: index2 [
    "Swap two issues in the collection"
    issues swap: index1 with: index2
]
