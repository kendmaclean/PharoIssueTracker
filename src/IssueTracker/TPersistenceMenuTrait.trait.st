Trait {
	#name : 'TPersistenceMenuTrait',
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'persistence' }
TPersistenceMenuTrait >> buildPersistenceMenu [
	"Build a menu with persistence options (backup, import, export)
	Note: Auto-save handles regular saves automatically"

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Create Backup';
				  icon: (self iconNamed: #smallSave);
				  action: [ self createBackup ] ];
		  addItem: [ :item |
			  item
				  name: 'Export to...';
				  icon: (self iconNamed: #smallSaveAs);
				  action: [ self exportIssues ] ];
		  addItem: [ :item |
			  item
				  name: 'Import from...';
				  icon: (self iconNamed: #smallExport);
				  action: [ self importIssues ] ];
		  addItem: [ :item |
			  item
				  name: 'Change Storage Location...';
				  icon: (self iconNamed: #home);
				  action: [ self changeStorageLocation ] ];
		  yourself
]

{ #category : 'persistence' }
TPersistenceMenuTrait >> changeStorageLocation [
	"Allow user to change the default persistence file location"
	| newFile currentFile |
	
	currentFile := IssueRepository uniqueInstance defaultPersistenceFileName.
	
	self inform: 'Current location: ', currentFile fullName.
	
	newFile := UIManager default 
		chooseForSaveFileReference: 'Choose New Storage Location' 
		extensions: #('fuel') 
		path: currentFile parent.
	
	newFile ifNotNil: [
		(self confirm: 'Change storage location to: ', newFile fullName, '?
		
This will:
1. Save current issues to new location
2. Use this as the default location going forward

Continue?') ifTrue: [
			"Save to new location"
			(IssueRepository uniqueInstance saveToFile: newFile) ifTrue: [
				"Update the default location"
				IssueRepository uniqueInstance customPersistenceFileName: newFile.
				self inform: 'Storage location changed to: ', newFile fullName, '

Issues have been saved to the new location.'
			] ifFalse: [
				self inform: 'Failed to save to new location'
			]
		]
	]
]

{ #category : 'persistence' }
TPersistenceMenuTrait >> createBackup [
	"Create a backup of current issues"
	| backupFile |
	backupFile := IssueRepository uniqueInstance createBackup.
	backupFile ifNotNil: [
		self inform: 'Backup created: ', backupFile basename
	] ifNil: [
		self inform: 'Backup failed or no issues to backup'
	]
]

{ #category : 'persistence' }
TPersistenceMenuTrait >> exportIssues [
	"Export issues to a user-selected file"
	| file |
	file := UIManager default 
		chooseForSaveFileReference: 'Export Issues' 
		extensions: #('fuel') 
		path: FileLocator home.
	
	file ifNotNil: [
		(IssueRepository uniqueInstance exportToFile: file) ifTrue: [
			self inform: 'Issues exported to: ', file basename
		]
	]
]

{ #category : 'persistence' }
TPersistenceMenuTrait >> importIssues [
	"Import issues from a user-selected file"
	| file |
	file := UIManager default 
		chooseExistingFileReference: 'Import Issues' 
		extensions: #('fuel') 
		path: FileLocator home.
	
	file ifNotNil: [
		(self confirm: 'This will replace current issues. Continue?') ifTrue: [
			(IssueRepository uniqueInstance loadFromFile: file) ifTrue: [
				self issueListChanged.
				self inform: 'Issues imported from: ', file basename
			]
		]
	]
]
