Class {
	#name : 'IssueRepository',
	#superclass : 'Object',
	#instVars : [
		'issues'
	],
	#classVars : [
		'UniqueInstance',
		'customPersistenceFile'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
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
	backupFile := self defaultPersistenceFile parent / 
		('issues-backup-', timestamp, '.fuel').
	
	(self saveToFile: backupFile) ifTrue: [ 
		^ backupFile
	] ifFalse: [
		^ nil
	]
]

{ #category : 'persistence' }
IssueRepository >> customPersistenceFile: aFileReference [
	"Set a custom persistence file location"
	customPersistenceFile := aFileReference
]

{ #category : 'persistence' }
IssueRepository >> defaultPersistenceFile [
	"Return the default file location for persisting issues"
	^ customPersistenceFile ifNil: [ 
		FileLocator imageDirectory / 'IssueTracker' / 'issues.fuel' ]
]

{ #category : 'persistence' }
IssueRepository >> ensurePersistenceDirectory [
	"Ensure the persistence directory exists"
	| directory |
	directory := self defaultPersistenceFile parent.
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
	^ self loadFromFile: self defaultPersistenceFile
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
	^ self saveToFile: self defaultPersistenceFile
]

{ #category : 'persistence' }
IssueRepository >> saveToFile: aFileReference [
	"Save all issues to the specified file using Fuel
	Fuel automatically handles all serialization!"
	
	self ensurePersistenceDirectory.
	
	[ 
		FLSerializer serialize: issues toFileNamed: aFileReference fullName.
		^ true
	] on: Error do: [ :ex |
		UIManager default inform: 'Error saving issues: ', ex messageText.
		^ false
	]
]

{ #category : 'initialization' }
IssueRepository >> swapIssueAt: index1 with: index2 [
    "Swap two issues in the collection"
    issues swap: index1 with: index2
]
